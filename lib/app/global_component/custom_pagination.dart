import 'package:flutter/material.dart';
import 'package:monitoring_kambing/app/global_component/custom_button.dart';
import 'package:monitoring_kambing/app/global_component/custom_card.dart';

class CustomPagination extends StatelessWidget {
  final int currentPage;
  final int totalPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const CustomPagination({
    Key? key,
    required this.currentPage,
    required this.totalPage,
    this.onPrevious,
    this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          text: "Previous Page",
          onPressed: onPrevious,
          bgColor: Color.fromARGB(255, 36, 36, 80),
          fgColor: Colors.white,
          textColor: Colors.white,
          width: 120,
          height: 40,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(
          width: 20,
        ),
        CustomCard(
          isColumn: false,
          width: 140,
          height: 40,
          single_text: "PAGE $currentPage OF $totalPage",
        ),
        const SizedBox(
          width: 20,
        ),
        CustomButton(
          onPressed: onNext,
          text: "Next Page",
          bgColor: Color.fromARGB(255, 36, 36, 80),
          fgColor: Colors.white,
          textColor: Colors.white,
          width: 120,
          height: 40,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }
}
