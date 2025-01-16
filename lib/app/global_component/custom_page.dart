import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPage extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String jobType;
  final double? width;
  final double? height;

  CustomPage({
    required this.imageUrl,
    required this.name,
    required this.jobType,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: height!,
      width: width!,
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 4, 16, 10)),
        color: Color.fromARGB(255, 227, 226, 226),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 100,
            backgroundColor: Color.fromARGB(255, 230, 225, 225),
            child: ClipOval(
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              ),
            ),
          ),
          SizedBox(height: 10),
          Flexible(
            child: Text(
              name,
              style: GoogleFonts.alike(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Flexible(
            child: Text(
              jobType,
              style: GoogleFonts.ramabhadra(
                color: const Color.fromARGB(255, 71, 71, 71),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
