import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class HomeIcon extends StatelessWidget {
  const HomeIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(AppColors.primaryColor)  
                  : Color(AppColors.cardsColor),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Colors.white
                  : Color(AppColors.primaryColor),
            ),
          ),
          SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              color: isSelected
                  ? Color(AppColors.primaryColor)
                  : Color(AppColors.secondaryColor),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}