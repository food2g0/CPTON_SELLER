import 'package:flutter/material.dart';

import '../colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? data;
  final String? hintText;
  final TextStyle? hintStyle;
  final bool isObsecure;
  final bool? enabled;
  final Widget? suffixIcon;
  final TextStyle? inputTextStyle; // Add inputTextStyle parameter

  CustomTextField({
    this.controller,
    this.data,
    this.hintText,
    this.hintStyle,
    required this.isObsecure,
    this.enabled,
    this.suffixIcon,
    this.inputTextStyle, // Initialize inputTextStyle parameter
  });

  String? _validateemail(String? value) {
    if (value == null || value.isEmpty) {
      return "Full Name is required";
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(value)) {
      return "Please enter a valid Full Name";
    }
    return null; // Input is valid
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(7),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        obscureText: isObsecure,
        validator: _validateemail,
        cursorColor: Theme.of(context).primaryColor,
        style: inputTextStyle, // Apply inputTextStyle to customize the input text style
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            data,
            color: AppColors().red,
          ),
          hintText: hintText,
          hintStyle: hintStyle,
          suffixIcon: suffixIcon,
          // Use the inputTextStyle for the input text style
          // Apply it to the text style of the input decoration
          // You can also apply other text styles such as font size, color, etc.
          // Here, we only modify the font family of the input text.
          // Feel free to customize it further as needed.
          // TextStyle(fontFamily: 'YourFontFamily'),
          // You can also use the provided hintStyle directly if you want the input text style to match the hint style.
        ),
      ),
    );
  }
}



