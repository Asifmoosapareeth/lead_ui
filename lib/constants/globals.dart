import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String baseURL = "http://127.0.0.1:8000/api/";
const Map<String,String> headers = {"content-Type": "application/json"};
void _showAlertDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}