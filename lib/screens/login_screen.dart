import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_dev_project/DB/MySQL.dart';
import 'package:mobile_dev_project/screens/register_screen.dart';
import 'package:mobile_dev_project/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Cafl',
                    style: GoogleFonts.lobster(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Best platform for organized learning and\nEntertainment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            final passwordRegex =
                            RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
                            if (!passwordRegex.hasMatch(value)) {
                              return 'Password must include letters and numbers';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A1B7D),
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var result = await MYSQL.loginUser(email: emailController.text, password: passwordController.text);
                              if(result != null) {
                                int userId = result['id'] as int;
                                SharedPreferences pref = await SharedPreferences
                                    .getInstance();
                                pref.setInt("id", userId);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                                );
                              }
                              else
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Login failed. Please try again.'),
                                    ),
                                  );
                                }
                            }
                          },
                          child: const Text('Login', style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  const Text("Don\'t have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate to RegisterScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Register here',
                      style: TextStyle(
                        color: Color(0xFF2A1B7D),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
