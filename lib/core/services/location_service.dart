import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // التحقق من صلاحية الموقع
  static Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }
  
  // طلب تشغيل الموقع (يظهر dialog)
  static Future<bool> requestLocationService(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    if (!serviceEnabled) {
      // عرض dialog للمستخدم
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // منع المستخدم من الخروج
        builder: (context) => WillPopScope(
          onWillPop: () async => false, // منع الضغط على back
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.location_off, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                const Text(
                  "خدمة الموقع",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "نحتاج تفعيل خدمة الموقع عشان نقدر نعرضلك الطلبات القريبة منك",
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "بدون الموقع، مش هتقدر تشوف الطلبات المتاحة",
                          style: TextStyle(color: Colors.blue[700], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // فتح إعدادات الموقع
                  await Geolocator.openLocationSettings();
                  Navigator.pop(context, false);
                },
                child: const Text("فتح الإعدادات"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("حاول مرة أخرى"),
              ),
            ],
          ),
        ),
      );
      
      if (result == true) {
        // التحقق مرة أخرى بعد محاولة المستخدم
        return await checkLocationPermission();
      }
      return false;
    }
    
    // التحقق من الصلاحية
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // عرض dialog للمستخدم أن الصلاحية ممنوعة نهائياً
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("الموقع ممنوع"),
          content: const Text(
            "تم منع صلاحية الموقع بشكل دائم. الرجاء تفعيلها من إعدادات الجهاز",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
                Navigator.pop(context);
              },
              child: const Text("فتح الإعدادات"),
            ),
          ],
        ),
      );
      return false;
    }
    
    return true;
  }
  
  // الحصول على الموقع الحالي
  static Future<Position?> getCurrentLocation() async {
    bool hasPermission = await checkLocationPermission();
    if (!hasPermission) return null;
    
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }
}