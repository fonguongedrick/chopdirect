import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FarmerEditProfile extends StatefulWidget {
  const FarmerEditProfile({super.key});

  @override
  State<FarmerEditProfile> createState() => _FarmerEditProfileState();
}

class _FarmerEditProfileState extends State<FarmerEditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _farmerData;

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _farmerTypeController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;
  late TextEditingController _facebookController;
  late TextEditingController _twitterController;
  late TextEditingController _instagramController;

  // Editable states for each field
  bool _nameEnabled = false;
  bool _phoneEnabled = false;
  bool _farmerTypeEnabled = false;
  bool _locationEnabled = false;
  bool _emailEnabled = false;
  bool _facebookEnabled = false;
  bool _twitterEnabled = false;
  bool _instagramEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchFarmerData();
  }

  Future<void> _fetchFarmerData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = await _firestore.collection('farmers_chopdirect').doc(user.uid).get();
    if (doc.exists) {
      _farmerData = doc.data();
      _nameController = TextEditingController(text: _farmerData?['name'] ?? '');
      _phoneController = TextEditingController(text: _farmerData?['phone'] ?? '');
      _farmerTypeController = TextEditingController(text: _farmerData?['farmerType'] ?? '');
      _locationController = TextEditingController(text: _farmerData?['location'] ?? '');
      _emailController = TextEditingController(text: _farmerData?['email'] ?? '');
      _facebookController = TextEditingController(text: _farmerData?['facebook'] ?? '');
      _twitterController = TextEditingController(text: _farmerData?['twitter'] ?? '');
      _instagramController = TextEditingController(text: _farmerData?['instagram'] ?? '');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore.collection('farmers_chopdirect').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'farmerType': _farmerTypeController.text.trim(),
        'location': _locationController.text.trim(),
        'email': _emailController.text.trim(),
        'facebook': _facebookController.text.trim(),
        'twitter': _twitterController.text.trim(),
        'instagram': _instagramController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required VoidCallback onEdit,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                prefixIcon: icon != null ? Icon(icon) : null,
                suffixIcon: IconButton(
                  icon: Icon(Icons.edit, color: enabled ? Colors.green : Colors.grey),
                  onPressed: onEdit,
                ),
              ),
              keyboardType: keyboardType,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildEditableField(
              label: 'Name',
              controller: _nameController,
              enabled: _nameEnabled,
              onEdit: () => setState(() => _nameEnabled = !_nameEnabled),
              icon: Icons.person,
            ),
            _buildEditableField(
              label: 'Phone',
              controller: _phoneController,
              enabled: _phoneEnabled,
              onEdit: () => setState(() => _phoneEnabled = !_phoneEnabled),
              keyboardType: TextInputType.phone,
              icon: Icons.phone,
            ),
            _buildEditableField(
              label: 'Farmer Type',
              controller: _farmerTypeController,
              enabled: _farmerTypeEnabled,
              onEdit: () => setState(() => _farmerTypeEnabled = !_farmerTypeEnabled),
              icon: Icons.agriculture,
            ),
            _buildEditableField(
              label: 'Location',
              controller: _locationController,
              enabled: _locationEnabled,
              onEdit: () => setState(() => _locationEnabled = !_locationEnabled),
              icon: Icons.location_on,
            ),
            _buildEditableField(
              label: 'Email',
              controller: _emailController,
              enabled: _emailEnabled,
              onEdit: () => setState(() => _emailEnabled = !_emailEnabled),
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email,
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Social Media Handles",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildEditableField(
              label: 'Facebook',
              controller: _facebookController,
              enabled: _facebookEnabled,
              onEdit: () => setState(() => _facebookEnabled = !_facebookEnabled),
              icon: Icons.facebook,
            ),
            _buildEditableField(
              label: 'Twitter',
              controller: _twitterController,
              enabled: _twitterEnabled,
              onEdit: () => setState(() => _twitterEnabled = !_twitterEnabled),
              icon: Icons.alternate_email,
            ),
            _buildEditableField(
              label: 'Instagram',
              controller: _instagramController,
              enabled: _instagramEnabled,
              onEdit: () => setState(() => _instagramEnabled = !_instagramEnabled),
              icon: Icons.camera_alt,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}