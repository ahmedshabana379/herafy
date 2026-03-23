import 'package:flutter/widgets.dart';
import 'package:herafy/core/resourses/app_colors.dart';

Widget BuildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Color(AppColors.primaryColor), size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }