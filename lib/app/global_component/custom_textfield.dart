import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isEnabled;
  final double? width;
  final double? height;
  final String? Function(String?)? validator;

  const CustomTextField(
      {Key? key,
      required this.hintText,
      required this.controller,
      required this.keyboardType,
      required this.obscureText,
      this.validator,
      this.width,
      this.height,
      required this.isEnabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 1,
            spreadRadius: 1,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: TextFormField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(6),
          enabled: isEnabled,
          border: InputBorder.none,
          errorStyle: const TextStyle(height: 0, fontSize: 0),
          errorBorder: InputBorder.none, // Remove error border
          focusedErrorBorder: InputBorder.none, // Remove focused error border
          errorMaxLines: 1,
          hintText: hintText,
          labelStyle: GoogleFonts.ramabhadra(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          hintStyle: GoogleFonts.ramabhadra(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
