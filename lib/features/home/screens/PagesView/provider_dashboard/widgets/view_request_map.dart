// lib/features/home/screens/PagesView/provider_dashboard/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:herafy/core/components/snack_bar_helper.dart';

class RequestMapScreen extends StatefulWidget {
  const RequestMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.isProvider = true,
    this.clientName,
    this.providerName,
  });

  final double latitude;
  final double longitude;
  final String locationName;
  final bool isProvider;
  final String? clientName;
  final String? providerName;

  @override
  State<RequestMapScreen> createState() => _RequestMapScreenState();
}

class _RequestMapScreenState extends State<RequestMapScreen> {
  late MapController _mapController;
  LatLng? _currentLocation;
  double? _distance;
  bool _isLoadingDistance = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocationAndDistance();
  }

  Future<void> _getCurrentLocationAndDistance() async {
    setState(() {
      _isLoadingDistance = true;
    });

    try {
      // جلب الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = LatLng(position.latitude, position.longitude);

      // حساب المسافة بين الموقع الحالي وموقع العميل
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.latitude,
        widget.longitude,
      );

      setState(() {
        _distance = distanceInMeters;
        _isLoadingDistance = false;
      });

    } catch (e) {
      setState(() {
        _isLoadingDistance = false;
      });
    }
  }

  String _getFormattedDistance() {
    if (_distance == null) return "غير معروف";
    if (_distance! < 1000) {
      return "${_distance!.toStringAsFixed(0)} متر";
    } else {
      return "${(_distance! / 1000).toStringAsFixed(1)} كم";
    }
  }

  void _centerOnMyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _mapController.move(LatLng(position.latitude, position.longitude), 15);

      SnackBarHelper.showSuccessSnackBar(context, "تم التمركز إلى موقعك الحالي");
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(context, "تعذر الحصول على موقعك الحالي");
    }
  }

  void _centerOnClientLocation() {
    _mapController.move(LatLng(widget.latitude, widget.longitude), 15);
  }

  @override
  Widget build(BuildContext context) {
    final targetLocation = LatLng(widget.latitude, widget.longitude);
    
    // ✅ التحقق من صحة الإحداثيات
    final isValidLocation = widget.latitude != 0 && widget.longitude != 0;
    
    if (!isValidLocation) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("موقع العميل"),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "لا يوجد موقع محدد للطلب",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final title = widget.isProvider
        ? "موقع العميل"
        : "موقع الحرفي";

    final markerTitle = widget.isProvider
        ? (widget.clientName ?? "العميل")
        : (widget.providerName ?? "الحرفي");

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // عرض الإحداثيات للتأكد
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                "${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ),
          // عرض المسافة
          if (_currentLocation != null && !_isLoadingDistance)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_walk, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        _getFormattedDistance(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: targetLocation,
              initialZoom: 14,
              onTap: (tapPosition, latLng) {
                // اختياري: لو عايز المستخدم يختار موقع
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.herafy.app',
              ),
              // ماركر موقع العميل/الحرفي
              MarkerLayer(
                markers: [
                  Marker(
                    point: targetLocation,
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: widget.isProvider ? Colors.red : Colors.green,
                          size: 48,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            markerTitle,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ماركر موقعي الحالي (لو موجود)
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 60,
                      height: 60,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 36,
                      ),
                    ),
                ],
              ),
              // رسم خط بين الموقعين
              if (_currentLocation != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_currentLocation!, targetLocation],
                      strokeWidth: 3,
                      color: Colors.blue.withOpacity(0.7),
                    ),
                  ],
                ),
            ],
          ),

          // ✅ نقطة المركز (اختيارية)
          if (_isLoadingDistance)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // أزرار التحكم السفلية
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زر التمركز على موقعي
                FloatingActionButton(
                  heroTag: null,
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _centerOnMyLocation,
                  child: const Icon(
                    Icons.my_location,
                    color: Color(0xFF6C63FF),
                    size: 24,
                  ),
                ),

                // عرض المسافة بشكل بارز
                if (_currentLocation != null && !_isLoadingDistance)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "المسافة",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getFormattedDistance(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                // زر التمركز على العميل
                FloatingActionButton(
                  heroTag: null,
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _centerOnClientLocation,
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Color(0xFF6C63FF),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}