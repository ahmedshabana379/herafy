import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:herafy/core/components/snack_bar_helper.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/core/services/location_service.dart';
import 'package:herafy/core/services/notification_service.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_cubit.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_state.dart';
import 'package:herafy/features/home/models/request_offer_model.dart';
import 'package:herafy/features/home/models/service_request_model.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/models/request_model.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/widgets/offer_dialog.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/widgets/request_card.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/widgets/view_request_map.dart';

class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key});
  static const String routeName = '/provider-dashboard';

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _locationEnabled = false;
  bool _isInitializing = true;
  Timer? _refreshTimer;
  bool _tabInitialized = false;

  // قوائم محلية للتحكم في حركة الطلبات
  List<ServiceRequestModel> _localInProgressRequests = [];
  List<ServiceRequestModel> _localCompletedRequests = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tabInitialized) {
      _tabInitialized = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      final initialTab = args?['initialTab'] as int? ?? 0;
      _tabController = TabController(
        length: 3,
        vsync: this,
        initialIndex: initialTab,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLocationAndLoadData();
  }

  void _syncLocalLists(
    List<ServiceRequestModel> apiInProgress,
    List<ServiceRequestModel> apiCompleted,
  ) {
    // الطلبات اللي في تنفيذ من API (status 1 أو 2)
    final newInProgress = apiInProgress
        .where((r) => r.requestStatus == 1 || r.requestStatus == 2)
        .toList();

    // الطلبات اللي انتهت من API (status 3)
    final newCompleted = apiCompleted
        .where((r) => r.requestStatus == 3)
        .toList();

    // الطلبات اللي انتهت من API لكن مش موجودة في القائمة المحلية
    for (var request in newCompleted) {
      if (!_localCompletedRequests.any((r) => r.id == request.id)) {
        _localCompletedRequests.insert(0, request);
        _localInProgressRequests.removeWhere((r) => r.id == request.id);
      }
    }

    // الطلبات الجديدة اللي في تنفيذ (ولسه موصلتش)
    for (var request in newInProgress) {
      if (!_localInProgressRequests.any((r) => r.id == request.id) &&
          !_localCompletedRequests.any((r) => r.id == request.id)) {
        _localInProgressRequests.add(request);
      }
    }
  }

  Future<void> _checkLocationAndLoadData() async {
    if (!mounted) return;
    setState(() => _isInitializing = true);

    bool locationReady = await LocationService.requestLocationService(context);
    if (!mounted) return;

    if (!locationReady) {
      setState(() {
        _isInitializing = false;
        _locationEnabled = false;
      });
      return;
    }

    setState(() => _locationEnabled = true);
    await _refreshAll();
    _startLiveLocation();

    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) _refreshAll();
    });

    if (!mounted) return;
    setState(() => _isInitializing = false);
  }

  Future<void> _refreshAll() async {
    if (_isInitializing) {
      await context.read<ServiceRequestCubit>().getProviderAvailableRequests();
      await context.read<ServiceRequestCubit>().getProviderAllRequests();
      await context.read<ServiceRequestCubit>().getProviderOffers();

      // مزامنة القوائم المحلية بعد جلب البيانات
      final cubit = context.read<ServiceRequestCubit>();
      final allAssigned = cubit.providerAssignedRequests;
      final completedFromApi = allAssigned
          .where((r) => r.requestStatus == 3)
          .toList();
      final inProgressFromApi = allAssigned
          .where((r) => r.requestStatus == 1 || r.requestStatus == 2)
          .toList();

      setState(() {
        _syncLocalLists(inProgressFromApi, completedFromApi);
      });
    } else {
      await context
          .read<ServiceRequestCubit>()
          .refreshProviderDashboardSilent();
    }
  }

  Future<void> _startLiveLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      context.read<ServiceRequestCubit>().startLiveLocationUpdates(
        initialLatitude: position.latitude,
        initialLongitude: position.longitude,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    context.read<ServiceRequestCubit>().stopLiveLocationUpdates();
    super.dispose();
  }

  Future<void> _submitOffer(ServiceRequestProviderModel request) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => OfferDialog(serviceName: 'طلب خدمة رقم ${request.id}'),
    );
    if (result == null || !mounted) return;

    try {
      await context.read<ServiceRequestCubit>().createRequestOffer(
        serviceRequestId: request.id,
        price: result['price'],
        message: result['message'],
      );
      if (!mounted) return;
      SnackBarHelper.showSuccessSnackBar(context, 'تم إرسال عرضك بنجاح ✓');
      await _refreshAll();
    } on DioException catch (e) {
      if (!mounted) return;
      SnackBarHelper.showErrorSnackBar(
        context,
        'فشل إرسال العرض: ${e.response?.data['message'] ?? 'حاول مرة أخرى'}',
      );
    }
  }

  void _openMap(ServiceRequestProviderModel request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestMapScreen(
          longitude: request.location.longitude,
          latitude: request.location.latitude,
          locationName: 'موقع العميل',
          isProvider: true,
          clientName: request.clientName,
        ),
      ),
    );
  }

  void _openMapForAssigned(ServiceRequestModel request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestMapScreen(
          longitude: request.location.longitude,
          latitude: request.location.latitude,
          locationName: 'موقع العميل',
          isProvider: true,
          clientName: 'عميل #${request.clientId}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final credits = context.watch<AuthCubit>().currentUser?.credits ?? 0;
    final jobsCount = context.watch<AuthCubit>().currentUser?.jobsCount ?? 0;

    return BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
      listener: (context, state) {
        if (state is CreateRequestOfferError) {
          SnackBarHelper.showErrorSnackBar(context, state.error);
        }
        if (state is GetProviderAvailableRequestsError) {
          SnackBarHelper.showErrorSnackBar(
            context,
            'خطأ في تحميل الطلبات: ${state.message}',
          );
        }

        if (state is OfferAcceptedNotification) {
          final cubit = context.read<ServiceRequestCubit>();
          final relatedRequest = cubit.providerAvailableRequests
              .where((r) => r.id == state.serviceRequestId)
              .firstOrNull;
          final clientName = relatedRequest?.clientName ?? 'العميل';

          NotificationService.addOfferAcceptedNotification(
            requestId: state.serviceRequestId,
            clientName: clientName,
            price: state.price,
          );

          SnackBarHelper.showSuccessSnackBar(
            context,
            '🎉 قبل $clientName عرضك! توجّه إليه الآن',
          );
          _tabController.animateTo(1);
        }

        if (state is GetProviderAssignedRequestsSuccess) {
          final cubit = context.read<ServiceRequestCubit>();
          final allAssigned = cubit.providerAssignedRequests;
          final completedFromApi = allAssigned
              .where((r) => r.requestStatus == 3)
              .toList();
          final inProgressFromApi = allAssigned
              .where((r) => r.requestStatus == 1 || r.requestStatus == 2)
              .toList();

          setState(() {
            _syncLocalLists(inProgressFromApi, completedFromApi);
          });
        }
      },
      builder: (context, state) {
        final cubit = context.read<ServiceRequestCubit>();

        // مزامنة أولية لو القوائم فاضية والـ cubit عنده بيانات
        if (_localInProgressRequests.isEmpty &&
            _localCompletedRequests.isEmpty &&
            cubit.providerAssignedRequests.isNotEmpty) {
          final allAssigned = cubit.providerAssignedRequests;
          final completedFromApi = allAssigned
              .where((r) => r.requestStatus == 3)
              .toList();
          final inProgressFromApi = allAssigned
              .where((r) => r.requestStatus == 1 || r.requestStatus == 2)
              .toList();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _syncLocalLists(inProgressFromApi, completedFromApi);
            });
          });
        }

        final allNewRequests = cubit.providerAvailableRequests
            .where((r) => r.requestStatus == 0)
            .toList();

        final inProgressRequests = _localInProgressRequests
            .where((r) => r.requestStatus == 1 || r.requestStatus == 2)
            .toList();

        final completedRequests = _localCompletedRequests
            .where((r) => r.requestStatus == 3)
            .toList();

        final apiCompleted = cubit.providerAssignedRequests
            .where((r) => r.requestStatus == 3)
            .toList();
        double totalEarnings = 0;
        for (var request in apiCompleted) {
          final price = request.finalPrice ?? 0;
          totalEarnings += price;
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(AppColors.primaryColor),
                                    Color(
                                      AppColors.primaryColor,
                                    ).withOpacity(0.75),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.account_balance_wallet_outlined,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'إجمالي الأرباح',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${totalEarnings.toStringAsFixed(0)} ج.م',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF43C59E),
                                    const Color(0xFF43C59E).withOpacity(0.75),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.savings_outlined,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'رصيدك',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$credits ج.م',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          _buildStatItem(
                            'جديدة',
                            '${allNewRequests.length}',
                            Icons.notifications_active_outlined,
                            const Color(0xFF6C63FF),
                          ),
                          _buildStatItem(
                            'تنفيذ',
                            '${inProgressRequests.length}',
                            Icons.build_circle_outlined,
                            const Color(0xFF43C59E),
                          ),
                          _buildStatItem(
                            'منتهية',
                            '$jobsCount',
                            Icons.task_alt,
                            const Color(0xFF5B8DEF),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                height: 44,
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
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: 'جديدة (${allNewRequests.length})'),
                    Tab(text: 'تنفيذ (${inProgressRequests.length})'),
                    Tab(text: 'منتهية ($jobsCount)'),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestsList(
                      allNewRequests,
                      showOfferButton: true,
                      myOffers: cubit.providerOffers,
                    ),
                    _buildInProgressList(inProgressRequests),
                    _buildCompletedList(completedRequests),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedList(List<ServiceRequestModel> requests) {
    if (requests.isEmpty) {
      return _buildEmptyState(Icons.task_alt, 'لا توجد خدمات منتهية');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildCompletedCard(requests[index]),
    );
  }

  Widget _buildCompletedCard(ServiceRequestModel request) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: Colors.teal, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب #${request.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  request.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 12, color: Colors.teal[400]),
                    const SizedBox(width: 4),
                    Text(
                      'مكتمل',
                      style: TextStyle(
                        color: Colors.teal[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (request.finalPrice != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${request.finalPrice!.toStringAsFixed(0)} ج.م',
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildRequestsList(
    List<ServiceRequestProviderModel> requests, {
    required bool showOfferButton,
    List<RequestOfferModel>? myOffers,
  }) {
    if (requests.isEmpty) {
      return _buildEmptyState(Icons.inbox_outlined, 'لا توجد طلبات جديدة');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = requests[index];
        final myOffer = myOffers?.firstWhere(
          (o) => o.serviceRequestId == request.id,
          orElse: () => RequestOfferModel(
            id: 0,
            serviceRequestId: 0,
            providerId: 0,
            price: 0,
            message: '',
            status: '',
            createdAt: DateTime.now(),
          ),
        );
        return RequestCard(
          myOffer: (myOffer?.id == 0) ? null : myOffer,
          request: request,
          onOffer: showOfferButton ? () => _submitOffer(request) : () {},
          onMapPressed: () => _openMap(request),
        );
      },
    );
  }

  Widget _buildInProgressList(List<ServiceRequestModel> requests) {
    if (requests.isEmpty) {
      return _buildEmptyState(Icons.work_outline, 'لا توجد طلبات قيد التنفيذ');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildInProgressCard(requests[index]),
    );
  }

  Widget _buildInProgressCard(ServiceRequestModel request) {
    final isInProgress = request.requestStatus == 2;
    final statusText = isInProgress ? 'قيد التنفيذ' : 'تم التعيين';
    final statusColor = isInProgress ? Colors.green : Colors.blue;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(AppColors.cardsColor),
                  child: Icon(
                    Icons.person_outline,
                    color: Color(AppColors.primaryColor),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلب #${request.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (request.finalPrice != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${request.finalPrice!.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF43C59E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(request.createdAt),
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _openMapForAssigned(request),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Color(AppColors.primaryColor).withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 16,
                    color: Color(AppColors.primaryColor),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'عرض موقع العميل',
                    style: TextStyle(
                      color: Color(AppColors.primaryColor),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  String _formatTime(String createdAt) {
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return 'منذ قليل';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقائق';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعات';
    return 'منذ ${diff.inDays} أيام';
  }
}
