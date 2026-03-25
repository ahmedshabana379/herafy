
import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(AppColors.primaryColor);
    const textColor = Color(AppColors.secondaryColor);
    const cardBgColor = Color(AppColors.cardsColor);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, size: 30, color: primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: textColor.withValues(alpha: 0.7)),
        ),
        trailing: Icon(
          Icons.info_outline_rounded,
          color: primaryColor.withValues(alpha: 0.5),
          size: 18,
        ),
      ),
    );
  }
}
