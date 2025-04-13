import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Logo and title
                  SvgPicture.asset(
                    'assets/logo.svg',
                    height: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Login to ChopDirect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Login form
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icon(Icons.phone),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text('Forgot Password?'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/buyer');
                                  },
                                  child: const Text('Login'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text('............Or login with...........'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(FontAwesomeIcons.google, color: Colors.green),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(FontAwesomeIcons.facebook, color: Colors.blue,),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Don\'t have an account?'),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/register');
                                    },
                                    child: const Text('Sign Up'),
                                  ),
                                ],
                              ),
                            ],
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

class RegistrationScreen extends StatelessWidget {
  final String userType;
  
  const RegistrationScreen({super.key, this.userType = 'buyer'});

  @override
  Widget build(BuildContext context) {
    final type = ModalRoute.of(context)?.settings.arguments ?? userType;
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
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Logo and title
                  SvgPicture.asset(
                    'assets/logo.svg',
                    height: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFarmer ? 'Farmer Registration' : 'Buyer Registration',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Registration form
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              if (isFarmer) ...[
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Farm Name',
                                    prefixIcon: Icon(Icons.store),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icon(Icons.phone),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Email (Optional)',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: Icon(Icons.lock),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              if (isFarmer) ...[
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Farm Location',
                                    prefixIcon: Icon(Icons.location_on),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Main Products',
                                    prefixIcon: Icon(Icons.shopping_basket),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'vegetables',
                                      child: Text('Vegetables'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'fruits',
                                      child: Text('Fruits'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'grains',
                                      child: Text('Grains'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'drinks',
                                      child: Text('Drinks'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'others',
                                      child: Text('Others'),
                                    ),
                                  ],
                                  onChanged: (value) {},
                                ),
                                const SizedBox(height: 16),
                              ],
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
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      isFarmer ? '/farmer' : '/buyer',
                                    );
                                  },
                                  child: const Text('Register'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Already have an account?'),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/login');
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}