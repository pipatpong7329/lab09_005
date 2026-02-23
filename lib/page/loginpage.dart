import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab09_005/page/showbooks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  get data => null;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      debugPrint("Username: ${_usernameController.text}");
      debugPrint("Password: ${_passwordController.text}");

      var json = jsonEncode({
        "username": _usernameController.text,
        "password": _passwordController.text,
      });
      var url = Uri.parse('http://10.0.2.2:4000/api/auth/login');

      try {
        var response = await http.post(
          url,
          body: json,
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        );
        if (response.statusCode == 200) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          var payload = jsonDecode(response.body)['payload'];
          var accessToken = jsonDecode(response.body)['accessToken'];
          var refreshToken = jsonDecode(response.body)['refreshToken'];
          await prefs.setInt('id', payload['userId']);
          await prefs.setString('user', payload['username']);
          await prefs.setString('role', payload['role']);
          await prefs.setString('accessToken', accessToken);
          await prefs.setString('refreshToken', refreshToken);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Showbooks(
                payload: payload,
                accessToken: accessToken,
                refreshToken: refreshToken,
              ),
            ),
          );

          debugPrint("Success: ${response.body}");
        } else {
          debugPrint("Failed: ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -50,
              child: _buildBlurCircle(250, const Color(0xFF00c6ff).withOpacity(0.15)),
            ),
            Positioned(
              bottom: 50,
              left: -40,
              child: _buildBlurCircle(200, const Color(0xFF0072ff).withOpacity(0.1)),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.scale(scale: value, child: child),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: 5,
                              )
                            ],
                            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                            color: Colors.white.withOpacity(0.05),
                          ),
                          child: const Icon(
                            Icons.lock_person_rounded,
                            size: 70,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'WELCOME',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 8,
                        ),
                      ),
                      Text(
                        'AUTHENTICATION SYSTEM',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 50),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(35),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1.2,
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildCustomTextField(
                                    controller: _usernameController,
                                    label: 'USERNAME',
                                    icon: Icons.alternate_email_rounded,
                                  ),
                                  const SizedBox(height: 25),
                                  _buildCustomTextField(
                                    controller: _passwordController,
                                    label: 'PASSWORD',
                                    icon: Icons.fingerprint_rounded,
                                    isPassword: true,
                                  ),
                                  const SizedBox(height: 40),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00c6ff).withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF00c6ff), Color(0xFF0072ff)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          height: 60,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'LOG IN',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "Don't have an account? Register Now",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 60,
            spreadRadius: 20,
          )
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF00c6ff), size: 22),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFF00c6ff), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            hintText: 'Enter your ${label.toLowerCase()}',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required field';
            }
            return null;
          },
        ),
      ],
    );
  }
}