import 'dart:io';
import 'package:chopdirect/constants/constanst.dart';
import 'package:chopdirect/screens/farmer/farmer_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class FarmerProfileSetUp extends StatefulWidget {
  const FarmerProfileSetUp({super.key});

  @override
  State<FarmerProfileSetUp> createState() => _FarmerProfileSetUpState();
}

class _FarmerProfileSetUpState extends State<FarmerProfileSetUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _profileImage;
  String? _profileImageUrl;
  bool _isLoading = false;
  bool _showSocialFields = false;

  String? _selectedFarmerType;
  final List<String> _farmerTypes = [
    "Poultry Farmer",
    "Livestock Farmer",
    "Crop Farmer",
    "Vegetable Farmer",
    "Fruit Farmer",
    "Mixed Farming"
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("farmers_chopdirect")
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        _nameController.text = doc.data()?['name'] ?? '';
        _phoneController.text = doc.data()?['phone'] ?? '';
        _locationController.text = doc.data()?['location'] ?? '';
        _facebookController.text = doc.data()?['facebook'] ?? '';
        _tiktokController.text = doc.data()?['tiktok'] ?? '';
        _twitterController.text = doc.data()?['twitter'] ?? '';
        _selectedFarmerType = doc.data()?['farmerType'];
        _profileImageUrl = doc.data()?['profileImageUrl'];
        _showSocialFields = (doc.data()?['facebook'] != null ||
            doc.data()?['tiktok'] != null ||
            doc.data()?['twitter'] != null);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      setState(() => _isLoading = true);
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('farmer_profile_images')
            .child('${FirebaseAuth.instance.currentUser?.uid}.jpg');

        await ref.putFile(_profileImage!);
        final url = await ref.getDownloadURL();

        setState(() {
          _profileImageUrl = url;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image uploaded!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading image: $e")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services disabled")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied")),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission permanently denied. Please enable it in settings.")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _locationController.text =
              '${place.locality ?? 'Unknown'}, ${place.country ?? 'Unknown'}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user logged in.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final profileData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'farmerType': _selectedFarmerType,
        'updatedAt': FieldValue.serverTimestamp(),
        'role': 'Farmer',
        'facebook': _facebookController.text.trim(),
        'tiktok': _tiktokController.text.trim(),
        'twitter': _twitterController.text.trim(),
      };

      if (_profileImageUrl != null) {
        profileData['profileImageUrl'] = _profileImageUrl;
      }

      await FirebaseFirestore.instance
          .collection("farmers_chopdirect")
          .doc(currentUser.uid)
          .set(profileData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully!")),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const FarmerHomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _facebookController.dispose();
    _tiktokController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your phone number";
    }
    final phoneRegExp = RegExp(r'^\+?\d{7,15}$');
    if (!phoneRegExp.hasMatch(value.trim())) return 'Enter a valid phone number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.pureWhite,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.secondaryGreen,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Section: Profile Picture
                        Text(
                          "Farmer Profile Setup",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.pureWhite,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Complete your profile to get started",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.pureWhite.withOpacity(0.85),
                              ),
                        ),
                        const SizedBox(height: 28),
                        Stack(
                          children: [
                            Animate(
                              effects: [
                                ScaleEffect(duration: 600.ms, curve: Curves.elasticOut)
                              ],
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.pureWhite.withOpacity(0.3),
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : _profileImageUrl != null
                                        ? NetworkImage(_profileImageUrl!)
                                        : null,
                                child: _profileImage == null && _profileImageUrl == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.pureWhite,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.accentYellow,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: AppColors.primaryGreen,
                                  ),
                                  onPressed: _isLoading ? null : _pickImage,
                                  padding: EdgeInsets.zero,
                                  iconSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Section: Basic Info
                        _sectionHeader("Basic Information"),
                        const SizedBox(height: 12),
                        Animate(
                          effects: [FadeEffect(duration: 500.ms)],
                          child: _buildTextField(
                            controller: _nameController,
                            label: "Farm Name",
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your name";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Animate(
                          effects: [FadeEffect(duration: 500.ms, delay: 100.ms)],
                          child: _buildTextField(
                            controller: _phoneController,
                            label: "Phone Number",
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: _validatePhone,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Animate(
                          effects: [FadeEffect(duration: 500.ms, delay: 200.ms)],
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _locationController,
                                  label: "Location",
                                  icon: Icons.location_on,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Please enter your location";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.gps_fixed, color: AppColors.pureWhite),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  padding: const EdgeInsets.all(16),
                                ),
                                onPressed: _isLoading ? null : _getCurrentLocation,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Animate(
                          effects: [FadeEffect(duration: 500.ms, delay: 300.ms)],
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Farmer Type",
                              labelStyle: const TextStyle(color: AppColors.primaryGreen),
                              prefixIcon: const Icon(Icons.agriculture, color: AppColors.primaryGreen),
                              filled: true,
                              fillColor: AppColors.pureWhite.withOpacity(0.15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            value: _selectedFarmerType,
                            items: _farmerTypes
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: const TextStyle(color: AppColors.primaryGreen),
                                      ),
                                    ))
                                .toList(),
                            onChanged: _isLoading
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      _selectedFarmerType = newValue;
                                    });
                                  },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please select your farmer type";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section: Social Media
                        _sectionHeader("Social Media (Optional)"),
                        Animate(
                          effects: [FadeEffect(duration: 500.ms, delay: 400.ms)],
                          child: InkWell(
                            onTap: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _showSocialFields = !_showSocialFields;
                                    });
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _showSocialFields
                                        ? 'Hide Social Media'
                                        : 'Add Social Media',
                                    style: TextStyle(
                                      color: AppColors.accentYellow,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  Icon(
                                    _showSocialFields
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: AppColors.accentYellow,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_showSocialFields) ...[
                          const SizedBox(height: 12),
                          Animate(
                            effects: [FadeEffect(duration: 500.ms)],
                            child: _buildTextField(
                              controller: _facebookController,
                              label: "Facebook Handle",
                              icon: Icons.facebook,
                              iconColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Animate(
                            effects: [FadeEffect(duration: 500.ms, delay: 100.ms)],
                            child: _buildTextField(
                              controller: _tiktokController,
                              label: "TikTok Handle",
                              icon: Icons.music_note,
                              iconColor: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Animate(
                            effects: [FadeEffect(duration: 500.ms, delay: 200.ms)],
                            child: _buildTextField(
                              controller: _twitterController,
                              label: "Twitter Handle",
                              icon: Icons.abc,
                              iconColor: Colors.lightBlue,
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),

                        // Save Profile Button
                        Animate(
                          effects: [ScaleEffect(duration: 500.ms)],
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentYellow,
                                foregroundColor: AppColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                shadowColor: AppColors.accentYellow.withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: AppColors.primaryGreen)
                                  : const Text(
                                      "SAVE PROFILE",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.accentYellow),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4.0, left: 2.0),
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.accentYellow,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Color iconColor = AppColors.primaryGreen,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isLoading,
      style: const TextStyle(color: AppColors.primaryGreen),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.primaryGreen),
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: AppColors.pureWhite.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}