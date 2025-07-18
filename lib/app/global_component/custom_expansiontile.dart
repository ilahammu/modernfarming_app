import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rounded_expansion_tile/rounded_expansion_tile.dart';

class CustomExpansionTile extends StatefulWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? children;

  const CustomExpansionTile({
    super.key,
    this.title,
    this.leading,
    this.children,
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          color: Colors.white, // Set the background color to white
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: Color.fromARGB(255, 202, 201, 201),
                  width: 1.5), // Set the border color and width
              borderRadius: BorderRadius.circular(10),
            ),
            child: RoundedExpansionTile(
              duration: const Duration(milliseconds: 350),
              horizontalTitleGap: 9,
              childrenPadding: const EdgeInsets.symmetric(horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              trailing: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              ),
              tileColor: Colors.white, // Set the tile color to white
              title: Text(
                widget.title!,
                style: GoogleFonts.ramabhadra(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: widget.leading,
              children: widget.children,
            ),
          ),
        );
      },
    );
  }
}
