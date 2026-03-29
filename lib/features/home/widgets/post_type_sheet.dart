import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/screens/create_post_screen.dart';

class PostTypeSheet extends StatelessWidget {
  const PostTypeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "نوع المنشور",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.primaryColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "اختر نوع المنشور اللي عايز تنشره",
            style: TextStyle(
              fontSize: 14,
              color: Color(AppColors.secondaryColor),
            ),
          ),
          const SizedBox(height: 24),

          // عرض خدمة
          _PostTypeOption(
            icon: Icons.handyman_rounded,
            title: "عرض خدمة",
            description: "انشر عرضك وخلي العملاء يطلبوا خدمتك مباشرة",
            onTap: () {
              Navigator.pushNamed(
                context,
                CreatePostScreen.routeName,
                arguments: "service",
              );
            },
          ),
          const SizedBox(height: 12),

          // مشاركة عامة
          _PostTypeOption(
            icon: Icons.public,
            title: "مشاركة عامة",
            description: "شارك شغلك مع المجتمع بدون طلب خدمة",
            onTap: () {
              Navigator.pop(context);
              // أو
              Navigator.pushNamed(
                context,
                CreatePostScreen.routeName,
                arguments: "general",
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PostTypeOption extends StatelessWidget {
  const _PostTypeOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(AppColors.cardsColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Color(AppColors.primaryColor), size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(AppColors.secondaryColor),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
