// lib/features/home/screens/PagesView/provider_dashboard/widgets/stat_card.dart
import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // ✅ ثبّتنا ارتفاع الكارد
      padding: const EdgeInsets.all(12), // ✅ قللنا padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4), 
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // ✅ مهم: ياخد أقل مساحة
        children: [
          Icon(icon, color: color, size: 24), // ✅ قللنا حجم الأيقونة
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16, // ✅ قللنا حجم الخط
              fontWeight: FontWeight.w900,
              color: Color(AppColors.primaryColor),
            ),
            overflow: TextOverflow.ellipsis, // ✅ لو طويل يتقطع
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10, // ✅ قللنا حجم الخط
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }
}
