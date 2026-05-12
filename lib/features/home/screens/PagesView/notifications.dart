import 'package:flutter/material.dart';
import 'package:herafy/core/services/notification_service.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/pages/provider_dashboard_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final notifications = NotificationService.notifications;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'الإشعارات',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('لا توجد إشعارات حالياً',
                              style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return _buildNotificationItem(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification item) {
    return GestureDetector(
      onTap: () {
        // ✅ mark as read
        setState(() => item.isRead = true);

        // ✅ روح للداشبورد وافتح تاب "تنفيذ" (index 1)
        Navigator.pushNamed(
          context,
          ProviderDashboardPage.routeName,
          arguments: {'initialTab': 1, 'requestId': item.requestId},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : Colors.indigo.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead ? Colors.grey.shade200 : Colors.indigo.withOpacity(0.15),
          ),
          boxShadow: item.isRead
              ? []
              : [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── أيقونة ──
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 22),
              ),
              const SizedBox(width: 12),
              // ── النص ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'قام ',
                        style: const TextStyle(fontSize: 14, height: 1.5),
                        children: [
                          TextSpan(
                            text: '${item.clientName} ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: 'بقبول عرضك'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تم خصم ${item.deductedPoints.toStringAsFixed(0)} نقطة من رصيدك',
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.touch_app_outlined,
                            size: 12, color: Colors.indigo[300]),
                        const SizedBox(width: 4),
                        Text(
                          'اضغط للتوجه للعميل الآن',
                          style: TextStyle(
                              color: Colors.indigo[400], fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(item.time),
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ),
              // ── نقطة "غير مقروء" ──
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقائق';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعات';
    return 'منذ ${diff.inDays} أيام';
  }
}