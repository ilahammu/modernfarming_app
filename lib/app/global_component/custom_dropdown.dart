import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDropdown extends StatelessWidget {
  final Rx<String?> selectedValue;
  final Function(String?) onChanged;
  final RxList<dynamic>
      items; // Changed to dynamic to support both maps and strings
  final String hintText;
  final bool isMap; // New parameter to specify if items are maps

  const CustomDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    required this.items,
    required this.hintText,
    this.isMap = true, // Default to true for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    // Sort items if they are maps
    final sortedItems = isMap
        ? (items.toList()
          ..sort((a, b) => a['nama_domba']!
              .toLowerCase()
              .compareTo(b['nama_domba']!.toLowerCase())))
        : items.toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 166, 212, 209)),
        color: Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 185, 187, 224),
            Color.fromARGB(255, 167, 215, 149),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 96, 99, 102),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(4, 1),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        margin: const EdgeInsets.all(0.5),
        child: DropdownButtonHideUnderline(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Obx(() => DropdownButton<String>(
                  dropdownColor: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                  isDense: true,
                  value: selectedValue.value?.isNotEmpty == true
                      ? selectedValue.value
                      : null,
                  icon: const Icon(Icons.arrow_drop_down),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  iconSize: 20,
                  elevation: 10,
                  hint: Align(
                    alignment: Alignment.center,
                    child: Text(
                      hintText, // Show hint text
                      style: GoogleFonts.ramabhadra(
                          color: Colors.black54, // Hint text color
                          fontWeight: FontWeight.normal,
                          fontSize: 14),
                    ),
                  ),
                  style: GoogleFonts.ramabhadra(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  onChanged: onChanged,
                  items: sortedItems.map<DropdownMenuItem<String>>((item) {
                    return DropdownMenuItem<String>(
                      value: isMap ? item['chip_id'] : item,
                      child: Text(isMap ? item['nama_domba']! : item),
                    );
                  }).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return sortedItems.map<Widget>((item) {
                      return Text(isMap ? item['nama_domba']! : item);
                    }).toList();
                  },
                )),
          ),
        ),
      ),
    );
  }
}
