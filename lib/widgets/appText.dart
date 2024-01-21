import 'package:flutter/material.dart';
import 'package:tce_dmdr/widgets/appColors.dart';

class AppText {
  static HeadingText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
    );
  }

  static brownBoldText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.darkBrown,
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
    );
  }

  static ContentText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    );
  }
}
