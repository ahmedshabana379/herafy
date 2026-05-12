// lib/features/home/screens/PagesView/offers_and_quick_request_for_client/tracking_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:herafy/core/components/snack_bar_helper.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_cubit.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_state.dart';
import 'package:herafy/features/home/screens/PagesView/offers_and_quick_request_for_client/widgets/review_dialog.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({
    super.key,
    required this.providerName,
    required this.serviceType,
    required this.price,
    required this.providerId,
    required this.serviceRequestId,
    this.requestStatus = 1,
  });

  final String providerName;
  final String serviceType;
  final double price;
  final String providerId;
  final String serviceRequestId;

  /// الحالة الأولية للطلب (1=Assigned, 2=InProgress, 3=Completed)
  final int requestStatus;

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  late MapController _mapController;
  LatLng? _providerLocation;
  LatLng? _currentLocation;
  double? _distance;
  bool _isLoadingLocation = true;
  bool _isCompleting = false;

  Timer? _locationTimer;
  Timer? _statusTimer;

  // حالة الطلب الحالية (تُحدَّث دوريًا من الـ API)
  late int _currentStatus;

  // -- خطوات التايم لاين --
  late List<Map<String, dynamic>> _steps;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentStatus = widget.requestStatus;
    _initSteps();
    _fetchCurrentLocation(); // جلب موقع العميل فوراً
    _startTracking();
    _startStatusPolling();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (_) {
      // الموقع غير متاح — نتجاهل
    }
  }

  void _initSteps() {
    _steps = [
      {'label': 'تم قبول العرض', 'completed': true},
      {'label': 'الحرفي في الطريق', 'completed': _currentStatus >= 1},
      {'label': 'بدأ العمل', 'completed': _currentStatus >= 2},
      {'label': 'تم الانتهاء', 'completed': _currentStatus >= 3},
    ];
  }

  void _updateSteps() {
    setState(() {
      _steps[1]['completed'] = _currentStatus >= 1;
      _steps[2]['completed'] = _currentStatus >= 2;
      _steps[3]['completed'] = _currentStatus >= 3;
    });
  }

  // ── Tracking ──────────────────────────────────────────────────────────────

  void _startTracking() {
    _fetchProviderLocation();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchProviderLocation();
    });
  }

  Future<void> _fetchProviderLocation() async {
    if (!mounted) return;
    try {
      await context.read<ServiceRequestCubit>().getLiveLocation(
        int.parse(widget.providerId),
      );
    } catch (_) {}
  }

  // ── Status Polling ────────────────────────────────────────────────────────

  void _startStatusPolling() {
    _pollStatus();
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _pollStatus();
    });
  }

  Future<void> _pollStatus() async {
    if (!mounted) return;
    try {
      // pollServiceRequestStatus بتجيب البيانات بصمت بدون إعادة بناء الشاشة
      await context.read<ServiceRequestCubit>().pollServiceRequestStatus(
        int.parse(widget.serviceRequestId),
      );
    } catch (_) {}
  }

  // ── Distance ──────────────────────────────────────────────────────────────

  void _calculateDistance() {
    if (_providerLocation != null && _currentLocation != null) {
      final meters = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _providerLocation!.latitude,
        _providerLocation!.longitude,
      );
      setState(() => _distance = meters / 1000);
    }
  }

  String get _distanceText {
    if (_distance == null) return 'غير معروف';
    if (_distance! < 1) return '${(_distance! * 1000).toInt()} متر';
    return '${_distance!.toStringAsFixed(1)} كم';
  }

  // ── Completion ────────────────────────────────────────────────────────────

  void _onCompletionPressed() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ReviewDialog(
        providerName: widget.providerName,
        serviceType: widget.serviceType,
        // agreedPrice: widget.price,
        onReviewSubmitted: (rating, comment) async {
          await _completeRequest(rating, comment);
        },
      ),
    );
  }

  Future<void> _completeRequest(double rating, String comment) async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);

    try {
      final cubit = context.read<ServiceRequestCubit>();

      // 1. تحديث الطلب كـ مكتمل
      await cubit.completeServiceRequest(int.parse(widget.serviceRequestId));

      // 2. إرسال التقييم
      await cubit.createReview(
        serviceRequestId: int.parse(widget.serviceRequestId),
        rating: rating,
        message: comment,
      );

      if (mounted) {
        Navigator.pop(context); // إغلاق الـ TrackingPage
        SnackBarHelper.showSuccessSnackBar(
          context,
          '✅ شكراً! تم إنهاء الخدمة وإرسال تقييمك',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCompleting = false);
        SnackBarHelper.showErrorSnackBar(
          context,
          'فشل إنهاء الطلب: ${e.toString()}',
        );
      }
    }
  }

  // ── Clean up ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _locationTimer?.cancel();
    _statusTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceRequestCubit, ServiceRequestState>(
      listener: (context, state) {
        // موقع الحرفي
        if (state is GetLiveLocationSuccess) {
          setState(() {
            _providerLocation = LatLng(
              state.location.latitude,
              state.location.longitude,
            );
            _isLoadingLocation = false;
          });
          _calculateDistance();
        }
        if (state is GetLiveLocationError) {
          setState(() => _isLoadingLocation = false);
        }

        // تحديث حالة الطلب من الـ polling
        if (state is GetServiceRequestByIdSuccess) {
          final newStatus = state.request.requestStatus;
          if (newStatus != _currentStatus) {
            setState(() => _currentStatus = newStatus);
            _updateSteps();
          }
        }

        // اكتمل الطلب من جانب الفني → فعّل زر الاستلام
        if (state is CompleteServiceRequestSuccess) {
          setState(() => _currentStatus = 3);
          _updateSteps();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('متابعة الخدمة - ${widget.serviceType}'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ── الخريطة ───────────────────────────────────────────────────
              SizedBox(height: 250, width: double.infinity, child: _buildMap()),

              // ── معلومات الحرفي ────────────────────────────────────────────
              _buildProviderCard(),

              const SizedBox(height: 16),

              // ── التايم لاين ───────────────────────────────────────────────
              _buildTimeline(),

              const SizedBox(height: 24),

              // ── زر الاستلام ───────────────────────────────────────────────
              _buildCompletionButton(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildMap() {
    // لو لسه بيجيب الموقع
    if (_isLoadingLocation &&
        _providerLocation == null &&
        _currentLocation == null) {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'جاري تحميل الخريطة...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // الموقع المركزي — الحرفي لو موجود، العميل لو لأ
    final centerPoint =
        _providerLocation ?? _currentLocation ?? const LatLng(30.0444, 31.2357);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: centerPoint, initialZoom: 14),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.herafy.app',
        ),
        MarkerLayer(
          markers: [
            // ماركر الحرفي
            if (_providerLocation != null)
              Marker(
                point: _providerLocation!,
                width: 60,
                height: 60,
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_pin_circle,
                      color: Colors.blue,
                      size: 40,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'الحرفي',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            // ماركر العميل
            if (_currentLocation != null)
              Marker(
                point: _currentLocation!,
                width: 60,
                height: 60,
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_pin_circle,
                      color: Colors.orange,
                      size: 40,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'أنت',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildProviderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(AppColors.cardsColor),
            child: Icon(
              Icons.person,
              size: 30,
              color: Color(AppColors.primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.providerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.serviceType,
                  style: TextStyle(
                    color: Color(AppColors.secondaryColor),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 14,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'المسافة: $_distanceText',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // حالة الطلب badge
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    switch (_currentStatus) {
      case 2:
        color = Colors.green;
        text = 'قيد التنفيذ';
        break;
      case 3:
        color = Colors.teal;
        text = 'مكتمل';
        break;
      default:
        color = Colors.blue;
        text = 'في الطريق';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                size: 20,
                color: Color(AppColors.primaryColor),
              ),
              const SizedBox(width: 8),
              Text(
                'حالة الخدمة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == _steps.length - 1;
            final isDone = step['completed'] as bool;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? Color(AppColors.primaryColor)
                              : Colors.grey[300],
                        ),
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: isDone
                              ? Color(AppColors.primaryColor)
                              : Colors.grey[300],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      step['label'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: isDone ? Colors.black : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompletionButton() {
    // الزر فعّال فقط لما status == 2 (الفني بدأ الشغل)
    final bool canComplete = _currentStatus == 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canComplete && !_isCompleting
              ? _onCompletionPressed
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(AppColors.primaryColor),
            disabledBackgroundColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isCompleting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  canComplete
                      ? '✅ تم الاستلام والتقييم'
                      : (_currentStatus == 3
                            ? '✔ تم إنهاء الخدمة'
                            : 'الخدمة قيد التنفيذ'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
