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
      // شلنا الـ height الثابت عشان الجريد هو اللي بيتحكم في الارتفاع بناءً على الـ Aspect Ratio
      padding: const EdgeInsets.all(8), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column( // شلنا الـ Expanded من هنا
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          FittedBox( // بيصغر الخط تلقائياً لو الرقم كبير عشان ميعملش Overflow
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(AppColors.primaryColor),
              ),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9, // صغرنا الخط شوية عشان الـ 4 كاردز جنب بعض مساحتهم ضيقة
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}