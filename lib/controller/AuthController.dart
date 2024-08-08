import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/globals.dart';
import '../view/loginpage.dart';


class AuthServices {
  static Future<http.Response> register(String name, String email, String password, String mobilePhone) async {
    Map data = {
      "name": name,
      "email": email,
      "password": password,
      "mobile_phone": mobilePhone,
    };

    var body = json.encode(data);
    var url = Uri.parse('${baseURL}auth/register');
    try {
      http.Response response = await http.post(url, headers: headers, body: body);
      return response;
    } catch (e) {
      print('Error registering user: $e');
      throw Exception('Failed to register user');
    }
  }

  static Future<http.Response> login(String email, String password) async {
    Map data = {
      "email": email,
      "password": password
    };
    var body = json.encode(data);
    var url = Uri.parse('${baseURL}auth/login');

    http.Response response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userName', responseData['user']['name']);
    }

    return response;
  }

  // static Future<void> logout(BuildContext context) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');
  //
  //   if (token != null) {
  //     var url = Uri.parse('${baseURL}logout');
  //     await http.post(url, headers: {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     });
  //
  //     await prefs.clear();
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginPage()),
  //     );
  //   }else{
  //     print("Logout Failed");
  //   }
  // }
  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      var url = Uri.parse('${baseURL}logout');
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        await prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        print("Logout failed with status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${response.statusCode}')),
        );
      }
    } else {
      print("Token not found");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found')),
      );
    }
  }

}

