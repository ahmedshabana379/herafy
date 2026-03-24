import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class RoleCard extends StatelessWidget {
  final String role;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Color(AppColors.fillColor) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Color(AppColors.primaryColor)
                : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        duration: const Duration(milliseconds: 250),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Color(AppColors.primaryColor),
                    size: 25,
                  )
                : Icon(Icons.circle_outlined, color: Colors.grey.shade400),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Color(AppColors.primaryColor)
                        : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? Color(AppColors.primaryColor)
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(AppColors.cardsColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 30, color: Color(AppColors.primaryColor)),
            ),
          ],
        ),
      ),
    );
  }
}
