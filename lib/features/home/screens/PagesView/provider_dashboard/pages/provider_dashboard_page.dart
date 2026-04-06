import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/widgets/stat_card.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/widgets/request_card.dart';

class ProviderDashboardPage extends StatelessWidget {
  const ProviderDashboardPage({super.key});

  static const List<Map<String, dynamic>> _mockRequests = [
    {
      "clientName": "محمد أحمد",
      "service": "سباك",
      "description":
          "تسريب مياه في الحمام وتغيير الوصلات القديمة من النوع الإيطالي لضمان الجودة.",
      "location": "المهندسين، الجيزة",
      "budget": 300,
      "timeAgo": "منذ 5 دقائق",
      "isUrgent": true,
    },
    {
      "clientName": "سارة علي",
      "service": "سباك",
      "description": "انسداد في بيارة المطبخ وصعوبة في تصريف المياه بشكل كامل.",
      "location": "مدينة نصر، القاهرة",
      "budget": 150,
      "timeAgo": "منذ 20 دقيقة",
      "isUrgent": false,
    },
    {
      "clientName": "كريم حسن",
      "service": "سباك",
      "description":
          "تركيب سخان جديد وتوصيل المواسير الخارجية مع العزل الحراري.",
      "location": "الزمالك، القاهرة",
      "budget": 500,
      "timeAgo": "منذ ساعة",
      "isUrgent": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StatsGrid(),
            const SizedBox(height: 28),
            _buildSectionHeader(),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mockRequests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  RequestCard(request: _mockRequests[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "الطلبات الواردة",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.primaryColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "لديك طلبات جديدة بانتظار العروض",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(AppColors.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "${_mockRequests.length} طلب",
            style: TextStyle(
              color: Color(AppColors.primaryColor),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4, // تعديل الـ Ratio لحل مشكلة الـ Overflow
      children: const [
        StatCard(
          title: "طلبات جديدة",
          value: "4",
          icon: Icons.notifications_active_outlined,
          color: Color(0xFF6C63FF),
        ),
        StatCard(
          title: "قيد التنفيذ",
          value: "2",
          icon: Icons.timer_outlined,
          color: Color(0xFFFFAA5A),
        ),
        StatCard(
          title: "مكتملة",
          value: "48",
          icon: Icons.task_alt,
          color: Color(0xFF43C59E),
        ),
        StatCard(
          title: "الأرباح",
          value: "12.5k",
          icon: Icons.payments_outlined,
          color: Color(0xFF5B8DEF),
        ),
      ],
    );
  }
}
