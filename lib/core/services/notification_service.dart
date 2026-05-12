// lib/core/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = 
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  
  // ✅ القائمة اللي بيستخدمها NotificationsPage
  static final List<AppNotification> notifications = [];
  static int _notifCounter = 0;

  // ✅ تهيئة بسيطة
  static Future<void> init() async {
    if (_initialized) return;
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings settings = 
        InitializationSettings(android: androidSettings);
    
    await _plugin.initialize(settings);
    _initialized = true;
  }

  // ✅ الدالة اللي بينادي عليها الداشبورد (المهمة)
  static Future<void> addOfferAcceptedNotification({
    required int requestId,
    required String clientName,
    required double price,
  }) async {
    const double deductedPoints = 25;

    // حفظ في القائمة المحلية عشان تظهر في NotificationsPage
    notifications.insert(0, AppNotification(
      id: _notifCounter++,
      requestId: requestId,
      clientName: clientName,
      price: price,
      deductedPoints: deductedPoints,
      time: DateTime.now(),
    ));

    // عرض الإشعار المنبثق
    await showOfferAccepted(
      clientName: clientName,
    );
  }

  // ✅ عرض الإشعار المنبثق
  static Future<void> showOfferAccepted({
    required String clientName,
  }) async {
    await init();
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'offers_channel',
      'عروض الحرفيين',
      channelDescription: 'إشعارات قبول العروض',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails details = 
        NotificationDetails(android: androidDetails);
    
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '🎉 تم قبول عرضك!',
      'قام $clientName بقبول عرضك - تم خصم 25 نقطة من رصيدك. توجه للعميل الآن!',
      details,
    );
  }
}

// ✅ كلاس الإشعار
class AppNotification {
  final int id;
  final int requestId;
  final String clientName;
  final double price;
  final double deductedPoints;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.requestId,
    required this.clientName,
    required this.price,
    required this.deductedPoints,
    required this.time,
    this.isRead = false,
  });
}