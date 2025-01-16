import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPagee extends StatelessWidget {
  final String imageUrl;
  final String nama_sensor;
  final String penjelasan;
  final double? width;
  final double? height;
  final bool isOdd;

  CustomPagee({
    required this.imageUrl,
    required this.nama_sensor,
    required this.penjelasan,
    required this.width,
    required this.height,
    required this.isOdd,
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
        ],
      ),
      child: Row(
        children: isOdd
            ? [
                Expanded(child: _buildText()),
                SizedBox(width: 20),
                _buildImage(),
              ]
            : [
                _buildImage(),
                SizedBox(width: 20),
                Expanded(child: _buildText()),
              ],
      ),
    );
  }

  Widget _buildImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          nama_sensor,
          style: GoogleFonts.alike(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        CircleAvatar(
          radius: 40,
          backgroundColor: Color.fromARGB(255, 230, 225, 225),
          child: ClipOval(
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              width: 80,
              height: 80,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            penjelasan,
            style: GoogleFonts.ramabhadra(
              color: const Color.fromARGB(255, 71, 71, 71),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 5, // Limit the number of lines to prevent overflow
          ),
        ),
      ],
    );
  }
}
