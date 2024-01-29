import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;

  MyTextField({this.hint, this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black, // Change the border color as needed
            width: 1.0, // Adjust the border width
          ),
          borderRadius: BorderRadius.circular(8.0), // Adjust border radius as needed
        ),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: EdgeInsets.all(10), // Adjust padding as needed
            border: InputBorder.none, // Remove the default border
          ),
          validator: (value) =>
          value!.isEmpty ? "Field cannot be empty" : null,
        ),
      ),
    );
  }
}
