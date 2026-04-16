// lib/features/home/screens/PagesView/provider_dashboard/provider_dashboard_page.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/core/services/location_service.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_cubit.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_state.dart';
import 'package:herafy/features/home/models/request_offer_model.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/models/request_model.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/widgets/offer_dialog.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/widgets/request_card.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/widgets/stat_card.dart';
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
  bool _locationEnabled = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkLocationAndLoadData();
  }

  Future<void> _checkLocationAndLoadData() async {
    if (!mounted) return;
    setState(() {
      _isInitializing = true;
    });

    bool locationReady = await LocationService.requestLocationService(context);
    if (!mounted) return;

    if (!locationReady) {
      setState(() {
        _isInitializing = false;
        _locationEnabled = false;
      });
      return;
    }

    setState(() {
      _locationEnabled = true;
    });

    await context.read<ServiceRequestCubit>().getProviderAvailableRequests();
    await context.read<ServiceRequestCubit>().getProviderAssignedRequests();
    await context.read<ServiceRequestCubit>().getProviderOffers();
    if (!mounted) return;
    setState(() {
      _isInitializing = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // في provider_dashboard_page.dart

  Future<void> _submitOffer(ServiceRequestModelProvider request) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => OfferDialog(
        requestBudget: request.budget,
        serviceName: "طلب خدمة رقم ${request.id}",
      ),
    );

    if (result == null || !mounted) return;

    try {
      await context.read<ServiceRequestCubit>().createRequestOffer(
        serviceRequestId: request.id,
        price: result['price'],
        message: result['message'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم إرسال عرضك بنجاح ✓"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
      // refresh بعد إرسال العرض
      await context.read<ServiceRequestCubit>().getProviderAvailableRequests();
      await context.read<ServiceRequestCubit>().getProviderAssignedRequests();
      await context.read<ServiceRequestCubit>().getProviderOffers();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "فشل إرسال العرض: ${e.response?.data['message'] ?? 'حاول مرة أخرى'}",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openMap(ServiceRequestModelProvider request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestMapScreen(
          latitude: request.latitude,
          longitude: request.longitude,
          locationName: "موقع العميل",
          isProvider: true,
          clientName: request.clientName ?? "العميل",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
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
              ],
            ),
          ),
        ),
      );
    }

    return BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
      listener: (context, state) {
        if (state is CreateRequestOfferSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(child: Text("تم إرسال العرض بنجاح")),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is CreateRequestOfferError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text(state.error)),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is GetProviderAvailableRequestsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text("خطأ في تحميل الطلبات: ${state.message}"),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ServiceRequestCubit>();
        print(
          "Available Requests Count: ${cubit.providerAvailableRequests.length}",
        );
        for (var req in cubit.providerAvailableRequests) {
          print(
            "Request: ${req.id} - ${req.clientName} - Status: ${req.requestStatus}",
          );
        }
        final myOffers = cubit.providerOffers;

// IDs الطلبات اللي بعت عليها عرض
final myOfferRequestIds = myOffers.map((o) => o.serviceRequestId).toSet();

// جديدة — مفيش عرض مني عليها
final pendingRequests = cubit.providerAvailableRequests
    .where((r) => r.requestStatus == 0 && !myOfferRequestIds.contains(r.id))
    .toList();

// عروضي — بعت عليها عرض وlسه pending
final offeredRequests = cubit.providerAvailableRequests
    .where((r) => myOfferRequestIds.contains(r.id))
    .toList();

// منتهية — status 3
final completedRequests = cubit.providerAssignedRequests
    .where((r) => r.requestStatus == 3)
    .toList();
        // for (var req in pendingRequests) {
        //   print("==========");
        //   print("طلب ID: ${req.id}");
        //   print("الإحداثيات: ${req.latitude}, ${req.longitude}");
        //   print(
        //     "هل الإحداثيات مصرية؟ ${req.latitude > 20 && req.latitude < 35 && req.longitude > 24 && req.longitude < 36}",
        //   );
        // }
        

        final stats = {
          'new': pendingRequests.length,
          'offered': offeredRequests.length,
          'completed': completedRequests.length,
        };

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: _StatsGrid(
                  newRequests: stats['new']!,
                  offeredRequests: stats['offered']!,
                  completed: stats['completed']!,
                ),
              ),

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
                  tabs: [
                    Tab(text: "جديدة (${stats['new']})"),
                    Tab(text: "عروضك (${stats['offered']})"),
                    Tab(text: "منتهية (${stats['completed']})"),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
  controller: _tabController,
  children: [
    _buildRequestsList(
      pendingRequests,
      showOfferButton: true,
    ),
    _buildRequestsList(
      offeredRequests,
      showOfferButton: false,
      myOffers: cubit.providerOffers, // ← جديد
    ),
    _buildRequestsList(
      completedRequests.cast<ServiceRequestModelProvider>(),
      showOfferButton: false,
    ),
  ],
),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestsList(
    List<ServiceRequestModelProvider> requests, {
    required bool showOfferButton,
    List<RequestOfferModel>? myOffers,
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
        final myOffer = myOffers?.firstWhere(
    (o) => o.serviceRequestId == request.id,
    // ← ممكن يكون null
  );
        return RequestCard(
           myOffer: myOffer,
          request: request,
          onOffer: showOfferButton ? () => _submitOffer(request) : () {},
          onMapPressed: () => _openMap(request),
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.newRequests,
    required this.offeredRequests,
    required this.completed,
  });

  final int newRequests;
  final int offeredRequests;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.2,
      children: [
        StatCard(
          title: "جديدة",
          value: "$newRequests",
          icon: Icons.notifications_active_outlined,
          color: const Color(0xFF6C63FF),
        ),
        StatCard(
          title: "عروضك",
          value: "$offeredRequests",
          icon: Icons.send_outlined,
          color: const Color(0xFFFFAA5A),
        ),
        StatCard(
          title: "منتهية",
          value: "$completed",
          icon: Icons.task_alt,
          color: const Color(0xFF43C59E),
        ),
        StatCard(
          title: "الأرباح",
          value: "0",
          icon: Icons.payments_outlined,
          color: const Color(0xFF5B8DEF),
        ),
      ],
    );
  }
}
