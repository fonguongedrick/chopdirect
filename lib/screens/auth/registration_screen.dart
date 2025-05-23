import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationScreen extends StatefulWidget {
  final String userType;

  const RegistrationScreen({super.key, this.userType = 'buyer'});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CountryCode? countryCode;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false; // Loading state

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      setState(() {
        isLoading = true; // Show loading animation
      });

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        createUserCredentials(userCredential);

        print("User registered: ${userCredential.user?.email}");

        // Navigate after success
        Navigator.pushReplacementNamed(
          context,
          widget.userType == 'farmer' ? '/farmer' : '/buyer',
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: $e")),
        );
      }

      setState(() {
        isLoading = false; // Hide loading animation
      });
    }
  }

  final countryPicker = FlCountryCodePicker(
      searchBarDecoration: InputDecoration(
          hintText: "Search country or Code",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          isDense: true
      ),
      filteredCountries:
      ["CM", "NG", "US", "GB", "CA", "DE", "FR", "IN", "ES"],
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Select Your Country",
              style:  TextStyle(
                  fontFamily: "OpenSansMedium",
                  fontSize: 15,
                  color: Color(0xff1B526B)
              ),
            ),
            GestureDetector(
                onTap: (){
                },
                child: Icon(Icons.close,size: 20,)
            ),
          ],
        ),
      ),
  );

  Future<void> createUserCredentials(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance.collection("users_chopdirect").add({
        "userId": userCredential.user!.uid, // Store Firebase UID
        "email": userCredential.user!.email,
        "name": fullNameController.text,
        "phoneNumber": "${countryCode?.dialCode ?? "+237"}${phoneController.text}",
      });
    }
  }

  @override
  void initState() {
    super.initState();
    countryCode = CountryCode.fromCode("CM");
  }


  @override
  Widget build(BuildContext context) {
    final type = ModalRoute.of(context)?.settings.arguments ?? widget.userType;
    final isFarmer = type == 'farmer';

    return Scaffold(
      body: Stack(
        children: [
          // Background with green gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green[800]!,
                  Colors.green[600]!,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 40),
                  ),

                  Center(
                    child: SvgPicture.asset(
                      'assets/logo.svg',
                      height: 100,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      isFarmer ? 'Farmer Registration' : 'Buyer Registration',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: fullNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: (value) =>
                                  value!.isEmpty ? 'Please enter full name' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: phoneController,
                                  decoration:  InputDecoration(
                                    labelText: 'Phone Number',
                                    prefixIcon: GestureDetector(
                                      onTap: () async{
                                        final code = await countryPicker.showPicker(context: context);
                                        if(code != null)
                                        setState(() {
                                          countryCode = code;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 13.0,left: 20),
                                        child: Text("${countryCode?.dialCode ?? "+237"}"),
                                      ),
                                    )
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) =>
                                  value!.isEmpty ? 'Please enter email' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: passwordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  obscureText: true,
                                  validator: (value) => value!.length < 6
                                      ? 'Password must be at least 6 characters'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: confirmPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Confirm Password',
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  obscureText: true,
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Checkbox(value: true, onChanged: (value) {}),
                                    const Expanded(
                                      child: Text(
                                        'I agree to the Terms and Conditions',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _registerUser,
                                    child: isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text('Register'),
                                  ),
                                ),

                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Already have an account?'),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/login',arguments: "buyer");
                                      },
                                      child: const Text('Login'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
