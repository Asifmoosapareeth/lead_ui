import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../controller/AuthController.dart';
import 'loginpage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _emailError = '';
  String _nameError = '';
  String _passwordError = '';
  String _phoneError = '';
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  createAccountPressed() async {
    setState(() {
      _emailError = '';
      _nameError = '';
      _passwordError = '';
      _phoneError = '';
    });

    bool emailValid = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(_emailController.text);
    bool phoneValid = RegExp(r"^[0-9]{10}$").hasMatch(_phoneController.text);

    if (emailValid && phoneValid) {
      http.Response response = await AuthServices.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _phoneController.text,
      );
      Map responseMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginPage(),
          ),
        );
      } else {
        if (responseMap.containsKey('name')) {
          setState(() {
            _nameError = responseMap['name'][0];
          });
        }
        if (responseMap.containsKey('email')) {
          setState(() {
            _emailError = responseMap['email'][0];
          });
        }
        if (responseMap.containsKey('password')) {
          setState(() {
            _passwordError = responseMap['password'][0];
          });
        }
        if (responseMap.containsKey('phone')) {
          setState(() {
            _phoneError = responseMap['phone'][0];
          });
        }
      }
    } else {
      setState(() {
        if (!emailValid) _emailError = 'Email is invalid';
        if (!phoneValid) _phoneError = 'Phone number is invalid';
      });
    }
  }
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
                    'Create an Account',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      TextField(

                        keyboardType: TextInputType.text,
                        controller: _nameController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Name',
                          hintStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.person, color: Colors.black54),
                          errorText: _nameError.isEmpty ? null : _nameError,
                          errorStyle: const TextStyle(color: Colors.redAccent),
                          focusedBorder: _buildBorder(Colors.teal),
                          enabledBorder: _buildBorder(Colors.black),
                        ),

                      ),
                      const SizedBox(height: 30),
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
                      const SizedBox(height: 30),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          focusedBorder: _buildBorder(Colors.teal),
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                          errorText: _passwordError.isEmpty ? null : _passwordError,
                          errorStyle: const TextStyle(color: Colors.redAccent),
                          enabledBorder: _buildBorder(Colors.black),

                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility : Icons.visibility_off,
                              color: Colors.black54,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.phone, color: Colors.black54),
                          errorText: _phoneError.isEmpty ? null : _phoneError,
                          errorStyle: const TextStyle(color: Colors.redAccent),
                            focusedBorder: _buildBorder(Colors.teal),
                          enabledBorder: _buildBorder(Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: ElevatedButton(
                    onPressed: createAccountPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.black87),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: const Text(
                        'Login',
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
