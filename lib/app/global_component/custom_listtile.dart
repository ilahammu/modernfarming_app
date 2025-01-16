import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomListTile extends StatefulWidget {
  final String? title;
  final IconData? iconLeading;
  final bool? isSelected;
  final VoidCallback onClick;

  const CustomListTile({
    super.key,
    this.title,
    this.iconLeading,
    required this.onClick,
    this.isSelected,
  });

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white, // Set the background color to white
      child: ListTile(
        onTap: () {
          widget.onClick();
        },
        dense: true,
        leading: Icon(
          widget.iconLeading!,
          color: widget.isSelected ?? false
              ? const Color.fromARGB(255, 0, 0, 0)
              : Colors.black,
          size: 15,
        ),
        titleAlignment: ListTileTitleAlignment.center,
        title: Text(
          widget.title!,
          style: GoogleFonts.ramabhadra(
            color: widget.isSelected ?? false
                ? const Color.fromARGB(255, 0, 0, 0)
                : const Color.fromARGB(255, 0, 0, 0),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
