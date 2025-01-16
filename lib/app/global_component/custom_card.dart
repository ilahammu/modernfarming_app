// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCard extends StatelessWidget {
  final String? single_text;
  final String? multiple_text;
  final String? multiple_text2;
  final double? width;
  final double? height;
  final bool isColumn;

  const CustomCard(
      {super.key,
      this.single_text,
      this.width,
      this.height,
      required this.isColumn,
      this.multiple_text,
      this.multiple_text2});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(7),
      height: height!,
      width: width!,
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 4, 16, 10)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 6, // Increased blurRadius for a more pronounced shadow
            spreadRadius: 2,
            offset: Offset(2, 5),
          ),
          BoxShadow()
        ],
      ),
      child: isColumn
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  multiple_text!,
                  style: GoogleFonts.ramabhadra(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
                Text(
                  multiple_text2!,
                  style: GoogleFonts.ramabhadra(
                      color: const Color(0xFF2E2BB7),
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            )
          : Text(
              single_text!,
              textAlign: TextAlign.center,
              style: GoogleFonts.ramabhadra(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
    );
  }
}
