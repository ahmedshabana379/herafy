

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/features/home/cubits/cubit/notifications_cubit_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  // قائمة وهمية للإشعارات (ممكن تربطها بـ API أو Local DB)
  List<Map<String, dynamic>> _allNotifications = [];
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;
  List<Map<String, dynamic>> get notifications => _allNotifications;

  // دالة لإضافة إشعار جديد (زي ما قلت لما العميل يقبل العرض)
  void addNotification({required String clientName, required double amount, required String service}) {
    final newNotif = {
      "clientName": clientName,
      "amount": (amount * 0.1).toStringAsFixed(2), // حساب الـ 10%
      "service": service,
      "time": "الآن",
      "isRead": false,
    };

    _allNotifications.insert(0, newNotif); // يضيفه في الأول
    _unreadCount++;
    
    emit(NotificationUpdated(count: _unreadCount, notifications: _allNotifications));
  }

  // دالة تصفير العداد لما نضغط على أيقونة الإشعارات
  void markAsRead() {
    _unreadCount = 0;
    // تحديث الحالة عشان الـ Badge يختفي
    emit(NotificationUpdated(count: _unreadCount, notifications: _allNotifications));
  }
}
