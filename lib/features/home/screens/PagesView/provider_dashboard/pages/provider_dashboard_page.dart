// lib/features/home/screens/PagesView/provider_dashboard/provider_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/core/services/location_service.dart';
import 'package:herafy/features/home/models/request_offer_model.dart';
import 'package:herafy/features/home/models/service_request_model.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/widgets/request_card.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/widgets/offer_dialog.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/widgets/view_request_map.dart';

class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key});
  static const String routeName = "/provider-dashboard";

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // قوائم الطلبات
  List<ServiceRequestModel> _pendingRequests =
      []; // طلبات جديدة (لم يقدم عليها عرض)
  List<ServiceRequestModel> _offeredRequests = []; // طلبات قدم عليها عرض
  List<ServiceRequestModel> _completedRequests = []; // طلبات منتهية

  // العروض اللي قدمها البروفايدر (لتخزينها محلياً)
  List<RequestOfferModel> _myOffers = [];
  bool _isLoading = true;
  bool _locationEnabled = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockData();
    _checkLocationAndLoadData();
  }

  Future<void> _checkLocationAndLoadData() async {
    setState(() {
      _isLoading = true;
    });

    // فحص وتشغيل الموقع
    bool locationReady = await LocationService.requestLocationService(context);

    if (!locationReady && mounted) {
      // لو المستخدم رفض الموقع، نعرض رسالة ونقفل الصفحة
      setState(() {
        _isLoading = false;
        _locationEnabled = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لا يمكن استخدام التطبيق بدون تفعيل خدمة الموقع"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      // نرجع للصفحة السابقة
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
      return;
    }

    setState(() {
      _locationEnabled = true;
    });

    // تحميل البيانات بعد تفعيل الموقع
    await _loadMockData();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMockData() async {
    final currentLocation = await LocationService.getCurrentLocation();
    if (currentLocation != null) {
      print(
        "الموقع الحالي: ${currentLocation.latitude}, ${currentLocation.longitude}",
      );
    }
    // طلبات جديدة (لم يقدم عليها عرض)
    _pendingRequests = [
      ServiceRequestModel(
        id: 1,
        description: "تسريب مياه في الحمام وتغيير الوصلات القديمة",
        serviceId: 1,
        serviceName: "سباك",
        budget: 300,
        latitude: 30.0444,
        longitude: 31.2357,
        locationAddress: "المهندسين، الجيزة",
        images: [],
        status: "Pending",
        createdAt: DateTime.now()
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
        clientName: "محمد أحمد",
        clientId: 101,
        isUrgent: true,
      ),
      ServiceRequestModel(
        id: 2,
        description: "انسداد في بيارة المطبخ وصعوبة في تصريف المياه",
        serviceId: 1,
        serviceName: "سباك",
        budget: 150,
        latitude: 30.0644,
        longitude: 31.2857,
        locationAddress: "مدينة نصر، القاهرة",
        images: [],
        status: "Pending",
        createdAt: DateTime.now()
            .subtract(const Duration(minutes: 20))
            .toIso8601String(),
        clientName: "سارة علي",
        clientId: 102,
        isUrgent: false,
      ),
      ServiceRequestModel(
        id: 3,
        description: "تركيب سخان جديد وتوصيل المواسير الخارجية",
        serviceId: 1,
        serviceName: "سباك",
        budget: 500,
        latitude: 30.0644,
        longitude: 31.2457,
        locationAddress: "الزمالك، القاهرة",
        images: [],
        status: "Pending",
        createdAt: DateTime.now()
            .subtract(const Duration(hours: 1))
            .toIso8601String(),
        clientName: "كريم حسن",
        clientId: 103,
        isUrgent: false,
      ),
    ];

    // طلبات قدم عليها عرض (مثال)
    _offeredRequests = [
      ServiceRequestModel(
        id: 4,
        description: "تغيير جميع الأسلاك الكهربائية للشقة",
        serviceId: 2,
        serviceName: "كهربائي",
        budget: 800,
        latitude: 30.0544,
        longitude: 31.2557,
        locationAddress: "مصر الجديدة، القاهرة",
        images: [],
        status: "Assigned", // Assigned معناها البروفايدر قدم عرض وتم تخصيصه
        createdAt: DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        clientName: "أحمد محمود",
        clientId: 104,
        isUrgent: false,
      ),
    ];

    // طلبات منتهية
    _completedRequests = [
      ServiceRequestModel(
        id: 5,
        description: "دهان غرفتين وصالون",
        serviceId: 4,
        serviceName: "نقاش",
        budget: 1200,
        latitude: 30.0344,
        longitude: 31.2257,
        locationAddress: "الدقي، الجيزة",
        images: [],
        status: "Completed",
        createdAt: DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
        clientName: "نهاد محمد",
        clientId: 105,
        isUrgent: false,
      ),
    ];

    setState(() {});
  }

  // تقديم عرض على طلب
  Future<void> _submitOffer(ServiceRequestModel request) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => OfferDialog(
        requestBudget: request.budget,
        serviceName: request.serviceName,
      ),
    );

    if (result != null && mounted) {
      // إنشاء عرض جديد
      final newOffer = RequestOfferModel(
        id: DateTime.now().millisecondsSinceEpoch,
        serviceRequestId: request.id,
        providerId: 1001,
        providerName: "أبو العز سباك",
        price: result['price'],
        message: result['message'],
        status: "Pending",
        createdAt: DateTime.now().toIso8601String(),
      );

      _myOffers.add(newOffer);

      // نقل الطلب من القائمة المعلقة إلى قائمة العروض المرسلة
      setState(() {
        _pendingRequests.removeWhere((r) => r.id == request.id);

        // إنشاء طلب جديد بنفس البيانات ولكن status = "Assigned"
        final updatedRequest = ServiceRequestModel(
          id: request.id,
          description: request.description,
          serviceId: request.serviceId,
          serviceName: request.serviceName,
          budget: request.budget,
          latitude: request.latitude,
          longitude: request.longitude,
          locationAddress: request.locationAddress,
          images: request.images,
          status: "Assigned", // تم تخصيصه
          createdAt: request.createdAt,
          clientName: request.clientName,
          clientId: request.clientId,
          isUrgent: request.isUrgent,
        );

        _offeredRequests.add(updatedRequest);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text("تم إرسال عرضك على طلب ${request.clientName} بنجاح"),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // فتح الخريطة - البروفايدر يشوف موقع العميل
  void _openMap(ServiceRequestModel request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestMapScreen(
          latitude: request.latitude,
          longitude: request.longitude,
          locationName: request.locationAddress,
          isProvider: true, // البروفايدر بيتفرج على موقع العميل
          clientName: request.clientName ?? "العميل",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(AppColors.primaryColor)),
              const SizedBox(height: 16),
              Text(
                "جاري التحقق من الموقع...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // إذا الموقع مش مفعل
    if (!_locationEnabled) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_disabled,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  "خدمة الموقع غير مفعلة",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "لا يمكننا عرض الطلبات بدون تفعيل خدمة الموقع",
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _checkLocationAndLoadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text("إعادة المحاولة"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("رجوع"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final stats = {
      'new': _pendingRequests.length,
      'offered': _offeredRequests.length,
      'completed': _completedRequests.length,
      'earnings': 12500,
    };

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "مرحباً بك 👋",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.primaryColor),
                          ),
                        ),
                        Text(
                          "أبو العز سباك",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    CircleAvatar(
                      backgroundColor: Color(
                        AppColors.primaryColor,
                      ).withOpacity(0.1),
                      child: Icon(
                        Icons.person_outline,
                        color: Color(AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _StatsGrid(
                  newRequests: stats['new']!,
                  offeredRequests: stats['offered']!,
                  completed: stats['completed']!,
                  earnings: stats['earnings']!,
                ),
              ],
            ),
          ),

          // Tabs
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Color(AppColors.primaryColor),
                borderRadius: BorderRadius.circular(16),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              // التحكم في المسافات بين التابات
              padding: EdgeInsets.zero, // إزالة padding الداخلي
              labelPadding: EdgeInsets.zero, // إزالة padding بين النص والتاب
              tabs: [
                Tab(text: "جديدة (${stats['new']})"),
                Tab(text: "عروض مرسلة (${stats['offered']})"),
                Tab(text: "منتهية (${stats['completed']})"),
              ],
            ),
          ),

          // TabBar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(_pendingRequests, showOfferButton: true),
                _buildRequestsList(_offeredRequests, showOfferButton: false),
                _buildRequestsList(_completedRequests, showOfferButton: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(
    List<ServiceRequestModel> requests, {
    required bool showOfferButton,
  }) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              showOfferButton ? "لا توجد طلبات جديدة" : "لا توجد طلبات",
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = requests[index];
        return RequestCard(
          request: request,
          onOffer: showOfferButton ? () => _submitOffer(request) : () {},
          onMapPressed: () => _openMap(request),
        );
      },
    );
  }
}

// Stats Grid
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.newRequests,
    required this.offeredRequests,
    required this.completed,
    required this.earnings,
  });

  final int newRequests;
  final int offeredRequests;
  final int completed;
  final int earnings;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _StatItem(
          title: "جديدة",
          value: "$newRequests",
          icon: Icons.notifications_active_outlined,
          color: const Color(0xFF6C63FF),
        ),
        _StatItem(
          title: "عروض مرسلة",
          value: "$offeredRequests",
          icon: Icons.send_outlined,
          color: const Color(0xFFFFAA5A),
        ),
        _StatItem(
          title: "منتهية",
          value: "$completed",
          icon: Icons.task_alt,
          color: const Color(0xFF43C59E),
        ),
        _StatItem(
          title: "الأرباح",
          value: "${(earnings / 1000).toStringAsFixed(1)}k",
          icon: Icons.payments_outlined,
          color: const Color(0xFF5B8DEF),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
