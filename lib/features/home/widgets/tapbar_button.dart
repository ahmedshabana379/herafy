import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class HomeIcon extends StatelessWidget {
  const HomeIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(AppColors.cardsColor),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 24, color: Color(AppColors.primaryColor)),
          ),
          SizedBox(height: 5),
          Text(text, style: TextStyle(color: Color(AppColors.secondaryColor))),
        ],
      ),
    );
  }
}
