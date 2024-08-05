import 'dart:convert';
import 'package:lead_enquiry/view/signuppage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../controller/AuthController.dart';
import 'homepage.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _emailError = '';
  String _passwordError = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  loginPressed() async {
    setState(() {
      _emailError = '';
      _passwordError = '';
      _isLoading = true;
    });

    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      http.Response response = await AuthServices.login(_emailController.text, _passwordController.text);

      try {
        if (response.statusCode == 200) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => BottomNavBarDemo(),
            ),
                (route) => false,
          );
        } else {
          Map responseMap = jsonDecode(response.body);
          if (responseMap.containsKey('email')) {
            setState(() {
              _emailError = responseMap['email'][0];
            });
          }
          if (responseMap.containsKey('password')) {
            setState(() {
              _passwordError = responseMap['password'][0];
            });
          } else {
            setState(() {
              _emailError = 'Error: ${response.body}';
            });
          }
        }

      } catch (e) {
        setState(() {
          _emailError = 'Exception: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        if (_emailController.text.isEmpty) _emailError = 'Enter email';
        if (_passwordController.text.isEmpty) _passwordError = 'Enter password';
        _isLoading = false; // Hide loading animation
      });
    }
  }
  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color,width: 2),
      borderRadius: BorderRadius.circular(10),

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 80),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.email, color: Colors.black54),
                          errorText: _emailError.isEmpty ? null : _emailError,
                          errorStyle: const TextStyle(color: Colors.redAccent),
                          focusedBorder: _buildBorder(Colors.teal),
                          enabledBorder: _buildBorder(Colors.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                          errorText: _passwordError.isEmpty ? null : _passwordError,
                          errorStyle: const TextStyle(color: Colors.redAccent),
                          focusedBorder: _buildBorder(Colors.teal),
                          enabledBorder: _buildBorder(Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : loginPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 24,
                    )
                        : const Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.black87),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
