// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCardNama extends StatelessWidget {
  final String? single_text;
  final double? width;
  final double? height;
  final bool isColumn;
  const CustomCardNama({
    super.key,
    this.single_text,
    this.width,
    this.height,
    required this.isColumn,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      height: height ?? 0,
      width: width ?? 0,
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
      child: Center(
        child: Text(
          single_text ?? '',
          textAlign: TextAlign.center,
          style: GoogleFonts.eczar(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
