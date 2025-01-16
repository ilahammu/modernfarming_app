// Custom Button

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color fgColor;
  final Color textColor;
  final double width;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final Function()? onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.bgColor,
    required this.fgColor,
    required this.textColor,
    required this.width,
    required this.height,
    required this.fontSize,
    required this.fontWeight,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      // ignore: deprecated_member_use
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(text,
            style: GoogleFonts.ramabhadra(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight)),
      ),
    );
  }
}
