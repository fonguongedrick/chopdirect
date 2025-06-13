
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../buyer_services/buyer_storage.dart';

class BuyerEditProfile extends StatefulWidget {
  const BuyerEditProfile({super.key});

  @override
  State<BuyerEditProfile> createState() => _BuyerEditProfileState();
}

class _BuyerEditProfileState extends State<BuyerEditProfile> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool isEditableName = false;
  bool isEditableEmail = false;
  bool isEditablePhone = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    if (currentUser == null) {
      return Future.error("User not logged in");
    }
    String? userId = currentUser?.uid;
    if (userId == null) {
      return Future.error("User not logged in");
    }
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection("users_chopdirect")
        .where("userId", isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return Future.error("No user data found!");
    }

    return querySnapshot.docs.first;
  }

  Future<void> updateUserField(String field, String value) async {
    if (currentUser == null) return;
    String? userId = currentUser?.uid;
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection("users_chopdirect")
        .where("userId", isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference userRef = querySnapshot.docs.first.reference;
      await userRef.update({field: value});
    }
  }

  Future<void> saveUserDetails() async {
    if (currentUser == null) return;
    String? userId = currentUser?.uid;

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection("users_chopdirect")
        .where("userId", isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference userRef = querySnapshot.docs.first.reference;
      await userRef.update({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phoneNumber": _phoneNumberController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> fetchImages() async {
    await Provider.of<StorageServices>(context, listen: false).fetchImages();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Email cannot be empty";
    if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,4}$").hasMatch(value.trim())) {
      return "Enter a valid email";
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return "Phone number cannot be empty";
    if (!RegExp(r'^\+?\d{7,15}$').hasMatch(value.trim())) {
      return "Enter a valid phone number";
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Name cannot be empty";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("ERROR: ${snapshot.error}"));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          Map<String, dynamic>? user = snapshot.data?.data();
          if (user == null) {
            return const Center(child: Text("User data is missing."));
          }

          // Pre-fill controllers only if empty (prevents overwriting edits)
          if (_nameController.text.isEmpty) {
            _nameController.text = user["name"] ?? "";
          }
          if (_emailController.text.isEmpty) {
            _emailController.text = user["email"] ?? "";
          }
          if (_phoneNumberController.text.isEmpty) {
            _phoneNumberController.text = user["phoneNumber"] ?? "";
          }

          return Consumer<StorageServices>(
            builder: (context, storageServices, child) {
              final List<String> imageUrl = storageServices.imageUrl;
              return Stack(
                children: [
                  // Back button
                  Positioned(
                    top: 50,
                    left: 25,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 40),
                    ),
                  ),
                  // Title
                  Positioned(
                    top: 60,
                    left: 170,
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Profile Image
                  Positioned(
                    top: 130,
                    left: 140,
                    child: CircleAvatar(
                      radius: 90,
                      backgroundColor: Colors.grey,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl.last)
                          : const AssetImage("assets/Ellipse 7.png") as ImageProvider,
                    ),
                  ),
                  // Camera Icon
                  Positioned(
                    top: 250,
                    left: 280,
                    child: GestureDetector(
                      onTap: () async {
                        await fetchImages();
                        await storageServices.uploadImage();
                        setState(() {});
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                  // Username
                  Positioned(
                    top: 370,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15, top: 15),
                            child: Text('Username', style: TextStyle(fontSize: 18)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                isEditableName
                                    ? Expanded(
                                        child: TextField(
                                          autofocus: isEditableName,
                                          controller: _nameController,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            fillColor: Colors.transparent,
                                            filled: true,
                                            errorText: null,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        user["name"] ?? "No User",
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                      ),
                                GestureDetector(
                                  onTap: () async {
                                    if (isEditableName) {
                                      String newName = _nameController.text.trim();
                                      if (_validateName(newName) == null) {
                                        setState(() => _isLoading = true);
                                        await updateUserField("name", newName);
                                        setState(() {
                                          user["name"] = newName;
                                          _isLoading = false;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Please enter a valid name.")),
                                        );
                                      }
                                    }
                                    setState(() {
                                      isEditableName = !isEditableName;
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isEditableName ? Icons.check : Icons.edit,
                                      color: Colors.green,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Email
                  Positioned(
                    top: 500,
                    left: 15,
                    right: 15,
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15, top: 15),
                            child: Text('Email', style: TextStyle(fontSize: 18)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                isEditableEmail
                                    ? Expanded(
                                        child: TextField(
                                          autofocus: isEditableEmail,
                                          controller: _emailController,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            fillColor: Colors.transparent,
                                            filled: true,
                                            errorText: null,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        user["email"] ?? "No Email",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                                      ),
                                GestureDetector(
                                  onTap: () async {
                                    if (isEditableEmail) {
                                      String newEmail = _emailController.text.trim();
                                      if (_validateEmail(newEmail) == null) {
                                        setState(() => _isLoading = true);
                                        await updateUserField("email", newEmail);
                                        setState(() {
                                          user["email"] = newEmail;
                                          _isLoading = false;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Please enter a valid email.")),
                                        );
                                      }
                                    }
                                    setState(() {
                                      isEditableEmail = !isEditableEmail;
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isEditableEmail ? Icons.check : Icons.edit,
                                      color: Colors.green,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Phone Number
                  Positioned(
                    top: 635,
                    left: 15,
                    right: 15,
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15, top: 15),
                            child: Text('Phone Number', style: TextStyle(fontSize: 18)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                isEditablePhone
                                    ? Expanded(
                                        child: TextField(
                                          autofocus: isEditablePhone,
                                          controller: _phoneNumberController,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            fillColor: Colors.transparent,
                                            filled: true,
                                            errorText: null,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        user["phoneNumber"] ?? "",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                                      ),
                                GestureDetector(
                                  onTap: () async {
                                    if (isEditablePhone) {
                                      String newPhone = _phoneNumberController.text.trim();
                                      if (_validatePhone(newPhone) == null) {
                                        setState(() => _isLoading = true);
                                        await updateUserField("phoneNumber", newPhone);
                                        setState(() {
                                          user["phoneNumber"] = newPhone;
                                          _isLoading = false;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Please enter a valid phone number.")),
                                        );
                                      }
                                    }
                                    setState(() {
                                      isEditablePhone = !isEditablePhone;
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isEditablePhone ? Icons.check : Icons.edit,
                                      color: Colors.green,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Save Button
                  Positioned(
                    top: 780,
                    left: 155,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : saveUserDetails,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text("Save Changes"),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}