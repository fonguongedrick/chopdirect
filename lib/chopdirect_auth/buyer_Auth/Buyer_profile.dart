import 'dart:io';
import 'package:chopdirect/chopdirect_auth/buyer_Auth/buyer_congratulations_dialog.dart';
import 'package:chopdirect/constants/constanst.dart';
import 'package:chopdirect/screens/buyer/buyer_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';

class BuyerProfileSetUp extends StatefulWidget {
  const BuyerProfileSetUp({super.key});

  @override
  State<BuyerProfileSetUp> createState() => _BuyerProfileState();
}

class _BuyerProfileState extends State<BuyerProfileSetUp> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _picker = ImagePicker();
  final countryPicker = const FlCountryCodePicker();

  File? _profileImage;
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  String? _imageUrl;
  CountryCode? countryCode;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateButtonState);
    _phoneController.addListener(_updateButtonState);
    _addressController.addListener(_updateButtonState);
    // Default to Cameroon
    countryCode = CountryCode(
      name: 'Cameroon',
      code: 'CM',
      dialCode: '+237',
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection("users_chopdirect")
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _nameController.text = data?['name'] ?? '';
          // Try to split country code and number if possible
          final phone = data?['phone'] ?? '';
          if (phone.startsWith('+')) {
            final match = RegExp(r'^(\+\d+)(.*)$').firstMatch(phone);
            if (match != null) {
              countryCode = CountryCode(
                name: countryCode?.name ?? 'Country',
                code: countryCode?.code ?? '',
                dialCode: match.group(1) ?? '+237',
              );
              _phoneController.text = match.group(2)?.replaceAll(RegExp(r'^\s*0*'), '') ?? '';
            } else {
              _phoneController.text = phone;
            }
          } else {
            _phoneController.text = phone;
          }
          _addressController.text = data?['address'] ?? '';
          _imageUrl = data?['profileImageUrl'];
        });
        _updateButtonState();
      }
    }
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _nameController.text.trim().isNotEmpty &&
          _phoneController.text.trim().isNotEmpty &&
          _addressController.text.trim().isNotEmpty;
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _imageUrl = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_profileImage == null) return _imageUrl;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return _imageUrl;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      await ref.putFile(_profileImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      if (!mounted) return _imageUrl;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return _imageUrl;
    }
  }

  Future<void> _showCountryPicker() async {
    final code = await countryPicker.showPicker(context: context);
    if (code != null && mounted) {
      setState(() => countryCode = code);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isButtonEnabled) return;

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Save phone as full international number
        final sanitizedPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
        final fullPhone = '${countryCode?.dialCode ?? '+237'}$sanitizedPhone';

        await FirebaseFirestore.instance
            .collection("users_chopdirect")
            .doc(user.uid)
            .update({
          'name': _nameController.text.trim(),
          'phone': fullPhone,
          'address': _addressController.text.trim(),
          'profileImageUrl': imageUrl,
          'profileComplete': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BuyerCongratulationsDialog(
          userName: _nameController.text.trim(),
          onClaim: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BuyerHomeScreen(
                initialIndex: 0,
              )),
            );
          },
        ),
      );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your name';
    if (value.trim().length < 2) return 'Name too short';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your phone number';
    // Basic validation: at least 7 digits
    final sanitized = value.replaceAll(RegExp(r'\D'), '');
    if (sanitized.length < 7) return 'Enter a valid phone number';
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your address';
    if (value.trim().length < 10) return 'Address too short';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Your Profile'),
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          centerTitle: true,
        ),
        body: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.2, 0.8],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture Section
                      Animate(
                        effects: [
                          ScaleEffect(duration: 500.ms, curve: Curves.elasticOut),
                          ShimmerEffect(delay: 300.ms, duration: 1000.ms),
                        ],
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.pureWhite,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.pureWhite.withOpacity(0.2),
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : (_imageUrl != null && _imageUrl!.isNotEmpty)
                                        ? NetworkImage(_imageUrl!)
                                        : null,
                                child: _profileImage == null && (_imageUrl == null || _imageUrl!.isEmpty)
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.pureWhite.withOpacity(0.7),
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentYellow,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.primaryGreen,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Name Field
                      Animate(
                        effects: [
                          SlideEffect(
                            duration: 500.ms,
                            begin: const Offset(-0.5, 0),
                            curve: Curves.easeOutCubic,
                          ),
                        ],
                        child: _buildTextField(
                          controller: _nameController,
                          label: "Full Name",
                          icon: Icons.person_outline,
                          validator: _validateName,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Phone Field with Country Picker
                      Animate(
                        effects: [
                          SlideEffect(
                            duration: 500.ms,
                            begin: const Offset(0.5, 0),
                            curve: Curves.easeOutCubic,
                            delay: 100.ms,
                          ),
                        ],
                        child: Row(
                          children: [
                            _buildCountryPicker(),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                controller: _phoneController,
                                label: "Phone Number",
                                icon: Icons.phone_iphone,
                                keyboardType: TextInputType.phone,
                                validator: _validatePhone,
                                isPhone: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Address Field
                      Animate(
                        effects: [
                          SlideEffect(
                            duration: 500.ms,
                            begin: const Offset(-0.5, 0),
                            curve: Curves.easeOutCubic,
                            delay: 200.ms,
                          ),
                        ],
                        child: _buildTextField(
                          controller: _addressController,
                          label: "Delivery Address",
                          icon: Icons.location_on_outlined,
                          maxLines: 2,
                          validator: _validateAddress,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Save Button
                      Animate(
                        effects: [
                          FadeEffect(duration: 600.ms),
                          ScaleEffect(duration: 400.ms),
                        ],
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_isButtonEnabled && !_isLoading)
                                ? _saveProfile
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentYellow,
                              foregroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                              shadowColor: AppColors.accentYellow.withOpacity(0.4),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: AppColors.primaryGreen,
                                    ),
                                  )
                                : const Text(
                                    "SAVE PROFILE",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryPicker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _showCountryPicker,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (countryCode?.flagUri != null)
                Image.asset(
                  countryCode!.flagUri,
                  package: 'fl_country_code_picker',
                  width: 24,
                ),
              const SizedBox(width: 8),
              Text(
                countryCode?.dialCode ?? '+237',
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: AppColors.pureWhite.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines = 1,
    bool isPhone = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.pureWhite),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.pureWhite.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: AppColors.pureWhite.withOpacity(0.7)),
        filled: true,
        fillColor: AppColors.pureWhite.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.accentYellow,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        errorStyle: const TextStyle(color: AppColors.errorRed),
      ),
    );
  }
}