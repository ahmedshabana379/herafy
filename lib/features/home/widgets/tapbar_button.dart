import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class HomeIcon extends StatelessWidget {
  const HomeIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.badgeCount = 0,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
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
                  color: isSelected ? Colors.white : Color(AppColors.primaryColor),
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
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