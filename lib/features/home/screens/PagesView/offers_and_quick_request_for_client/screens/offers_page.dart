import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/snack_bar_helper.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_cubit.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_state.dart';
import 'package:herafy/features/home/models/request_offer_model.dart';
import 'package:herafy/features/home/models/service_request_model.dart';
import 'package:herafy/features/home/screens/PagesView/offers_and_quick_request_for_client/screens/tracking_page.dart';
import 'package:herafy/features/home/screens/PagesView/offers_and_quick_request_for_client/widgets/offer_card.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key, this.scrollController});
  final ScrollController? scrollController;
  static const String routeName = '/offers_page';

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // ✅ 3 بس
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final cubit = context.read<ServiceRequestCubit>();
    await cubit.getClientServiceRequests();
    await cubit.loadAllClientRequestOffers();
  }

  List<RequestOfferModel> _pendingOffers(ServiceRequestCubit cubit) {
  final pendingRequestIds = cubit.clientRequests
      .where((r) => r.requestStatus == 0)
      .map((r) => r.id)
      .toSet();

  return cubit.allClientOffers
      .where((o) =>
          pendingRequestIds.contains(o.serviceRequestId) &&
          (o.status == null || o.status!.toLowerCase() == 'pending'))
      .toList();
}

  List<ServiceRequestModel> _inProgressRequests(ServiceRequestCubit cubit) =>
      cubit.clientRequests
          .where((r) => r.requestStatus == 1 || r.requestStatus == 2)
          .toList();

  List<ServiceRequestModel> _completedRequests(ServiceRequestCubit cubit) =>
      cubit.clientRequests.where((r) => r.requestStatus == 3).toList();

  Future<void> _acceptOffer(RequestOfferModel offer) async {
  if (offer.serviceRequestId == null || offer.providerId == null) {
    SnackBarHelper.showErrorSnackBar(context, "بيانات العرض ناقصة");
    return;
  }

  try {
    await context.read<ServiceRequestCubit>().assignServiceRequest(
      requestId: offer.serviceRequestId!,
      providerId: offer.providerId!,
    );

    if (mounted) {
      context.read<ServiceRequestCubit>().allClientOffers.removeWhere(
        (o) => o.serviceRequestId == offer.serviceRequestId,
      );
      SnackBarHelper.showSuccessSnackBar(
        context,
        "✅ تم قبول عرض ${offer.providerName ?? 'الحرفي'}",
      );
      await _loadData();
    }
  } catch (e) {
    if (mounted) {
      SnackBarHelper.showErrorSnackBar(context, "حدث خطأ، حاول تاني");
    }
  }
}

  void _trackService(ServiceRequestModel request) {
    // ابحث عن الـ offer المقبولة
    final cubit = context.read<ServiceRequestCubit>();
    final acceptedOffer = cubit.allClientOffers.firstWhere(
      (o) =>
          o.serviceRequestId == request.id &&
          o.status?.toLowerCase() == 'accepted',
      orElse: () => RequestOfferModel(
        id: 0,
        serviceRequestId: request.id,
        providerId: request.providerId,
        price: request.finalPrice ?? 0,
        message: '',
        createdAt: DateTime.now(),
        status: 'accepted',
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackingPage(
          providerName: acceptedOffer.providerName ?? 'الحرفي',
          serviceType: request.description,
          price: acceptedOffer.price,
          serviceRequestId: '${request.id}',
          providerId: '${acceptedOffer.providerId}',
          requestStatus: request.requestStatus,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
      listenWhen: (_, current) =>
    current is AssignServiceRequestSuccess ||
    current is AssignServiceRequestError,
listener: (context, state) {
  if (state is AssignServiceRequestSuccess) {
    SnackBarHelper.showSuccessSnackBar(context, "✅ تم قبول العرض");
  }
  if (state is AssignServiceRequestError) {
    SnackBarHelper.showErrorSnackBar(context, state.error);
  }
},
      builder: (context, state) {
        final cubit = context.read<ServiceRequestCubit>();
        final pending = _pendingOffers(cubit);
        final inProgress = _inProgressRequests(cubit);
        final completed = _completedRequests(cubit);
        final isLoading =
            state is GetClientServiceRequestsLoading ||
            state is GetRequestOffersLoading;

        return Material(
          color: Colors.transparent,
          child: Column(
            children: [
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: "جديدة (${pending.length})"),
                    Tab(text: "قيد التنفيذ (${inProgress.length})"),
                    Tab(text: "مكتملة (${completed.length})"),
                  ],
                ),
              ),
              if (isLoading && cubit.clientRequests.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOffersList(pending, cubit: cubit),
                      _buildInProgressList(inProgress),
                      _buildCompletedList(completed),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOffersList(
    List<RequestOfferModel> offers, {
    ServiceRequestCubit? cubit,
  }) {
    if (offers.isEmpty) return _buildEmptyState('لا توجد عروض جديدة');

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return OfferCard(
          offer: {
            'id': offer.id,
            'name': offer.providerName ?? 'حرفي',
            'price': offer.price,
            'message': offer.message,
            'status': offer.status?.toLowerCase() ?? 'pending',
            'providerId': offer.providerId,
            'serviceRequestId': offer.serviceRequestId,
            'providerPictureUrl': offer.providerPictureUrl,
          },
          onAccept: () => _acceptOffer(offer),
          onReject: () {},
          onTrack: () {},
        );
      },
    );
  }

  Widget _buildInProgressList(List<ServiceRequestModel> requests) {
    if (requests.isEmpty) return _buildEmptyState('لا توجد خدمات قيد التنفيذ');

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) =>
          _buildRequestCard(requests[index], isCompleted: false),
    );
  }

  Widget _buildCompletedList(List<ServiceRequestModel> requests) {
    if (requests.isEmpty) return _buildEmptyState('لا توجد خدمات مكتملة');

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) =>
          _buildRequestCard(requests[index], isCompleted: true),
    );
  }

  Widget _buildRequestCard(
    ServiceRequestModel request, {
    required bool isCompleted,
  }) {
    final cubit = context.read<ServiceRequestCubit>();

    // ابحث عن الـ offer المقبولة عشان تاخد اسم وصورة الحرفي
    RequestOfferModel? acceptedOffer;
    try {
      acceptedOffer = cubit.allClientOffers.firstWhere(
        (o) =>
            o.serviceRequestId == request.id &&
            o.status?.toLowerCase() == 'accepted',
      );
    } catch (_) {}

    final providerName = acceptedOffer?.providerName ?? 'الحرفي';
    final providerImage = acceptedOffer?.providerPictureUrl;
    final price = request.finalPrice ?? acceptedOffer?.price ?? 0;
    final statusText = isCompleted ? 'مكتمل' : request.statusText;
    final statusColor = isCompleted ? Colors.teal : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة الحرفي
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(AppColors.cardsColor),
                  backgroundImage:
                      providerImage != null && providerImage.isNotEmpty
                      ? NetworkImage(
                          'https://iti-final-project.runasp.net/$providerImage',
                        )
                      : null,
                  child: providerImage == null || providerImage.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 28,
                          color: Color(AppColors.primaryColor),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // اسم الحرفي + badge الحالة
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              providerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
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
                        ],
                      ),
                      const SizedBox(height: 6),
                      // وصف الطلب
                      Text(
                        request.description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // التاريخ
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(request.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // السعر + زرار متابعة
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${price.toStringAsFixed(0)} ج.م",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (!isCompleted)
                  ElevatedButton.icon(
                    onPressed: () => _trackService(request),
                    icon: const Icon(Icons.track_changes, size: 16),
                    label: const Text("متابعة"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.primaryColor),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                if (isCompleted)
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.teal, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "مكتملة",
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildEmptyState(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
