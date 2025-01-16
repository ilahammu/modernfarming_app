import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CustomDateFieldDombaa extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isEnabled;
  final double? width;
  final double? height;
  final ValueChanged<DateTime?>? onDateSelected;

  const CustomDateFieldDombaa({
    Key? key,
    required this.hintText,
    required this.controller,
    this.width,
    this.height,
    this.onDateSelected,
    required this.isEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: width ?? double.infinity,
        maxHeight: height ?? double.infinity,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 0.1,
            spreadRadius: 0.1,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today),
          enabled: isEnabled,
          border: InputBorder.none,
          hintText: hintText,
          isDense: true,
          errorStyle: const TextStyle(
            height: 0,
            fontSize: 0,
          ),
          errorBorder: InputBorder.none, // Remove error border
          focusedErrorBorder: InputBorder.none, // Remove focused error border
          errorMaxLines: 1,
          contentPadding: const EdgeInsets.all(3),
          hintStyle: GoogleFonts.ramabhadra(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          labelStyle: GoogleFonts.ramabhadra(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        textAlign: TextAlign.center,
        onTap: () async {
          FocusScope.of(context).requestFocus(
              FocusNode()); // to prevent opening the onscreen keyboard
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2030),
          );
          if (pickedDate != null) {
            String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
            controller.text = formattedDate;
            onDateSelected?.call(pickedDate);
          }
        },
      ),
    );
  }
}
