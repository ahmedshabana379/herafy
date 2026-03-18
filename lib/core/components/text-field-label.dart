
import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class TextFieldLabel extends StatelessWidget {
  const TextFieldLabel({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(AppColors.primaryColor),
        ),
      ),
    );
  }
}