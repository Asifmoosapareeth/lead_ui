import 'package:flutter/material.dart';
import '../Model/leaddata_model.dart';

class IconText extends StatelessWidget {
  const IconText({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 15),
        Text(text,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
      ],
    );
  }
}
