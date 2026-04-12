// lib/features/home/screens/PagesView/offers_and_quick_request_for_client/offers_page.dart
import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/screens/PagesView/offers_and_quick_request_for_client/screens/tracking_page.dart';
import 'package:herafy/features/home/screens/PagesView/offers_and_quick_request_for_client/widgets/offer_card.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key, this.scrollController});
  final ScrollController? scrollController;
  static const String routeName = "/offers_page";
  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data مقسمة حسب الحالة
  List<Map<String, dynamic>> _pendingOffers = [];
  List<Map<String, dynamic>> _acceptedOffers = [];
  List<Map<String, dynamic>> _completedOffers = [];
  List<Map<String, dynamic>> _rejectedOffers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    _pendingOffers = [
      {
        "id": "1",
        "name": "أحمد السباك",
        "job": "سباك محترف",
        "price": 350,
        "description": "هقوم بإصلاح التسريب وتغيير الوصلات القديمة باحترافية",
        "rating": 4.8,
        "completedJobs": 120,
        "status": "pending",
        "serviceRequestId": "req_1",
        "providerId": "prov_1",
      },
      {
        "id": "2",
        "name": "محمد علي",
        "job": "سباك معتمد",
        "price": 280,
        "description": null,
        "rating": 4.5,
        "completedJobs": 85,
        "status": "pending",
        "serviceRequestId": "req_1",
        "providerId": "prov_2",
      },
    ];

    _acceptedOffers = [
      {
        "id": "3",
        "name": "كريم حسن",
        "job": "فني صرف صحي",
        "price": 400,
        "description": "خبرة 10 سنين في الصرف والمواسير مع ضمان على الشغل",
        "rating": 4.9,
        "completedJobs": 200,
        "status": "accepted",
        "serviceRequestId": "req_2",
        "providerId": "prov_3",
      },
    ];

    _completedOffers = [
      {
        "id": "4",
        "name": "طارق محمود",
        "job": "سباك",
        "price": 200,
        "description": null,
        "rating": 4.2,
        "completedJobs": 45,
        "status": "completed",
        "serviceRequestId": "req_3",
        "providerId": "prov_4",
      },
    ];

    _rejectedOffers = [];
  }

  void _acceptOffer(Map<String, dynamic> offer) {
    _showConfirmDialog(
      isAccept: true,
      name: offer['name'],
      onConfirm: () {
        setState(() {
          _pendingOffers.remove(offer);
          _acceptedOffers.add({...offer, 'status': 'accepted'});
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("تم قبول عرض ${offer['name']}")));
      },
    );
  }

  void _rejectOffer(Map<String, dynamic> offer) {
    _showConfirmDialog(
      isAccept: false,
      name: offer['name'],
      onConfirm: () {
        setState(() {
          _pendingOffers.remove(offer);
          _rejectedOffers.add({...offer, 'status': 'rejected'});
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("تم رفض عرض ${offer['name']}")));
      },
    );
  }

  void _trackService(Map<String, dynamic> offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackingPage(
          providerName: offer['name'],
          serviceType: offer['job'],
          price: offer['price'],
          providerId: offer['providerId'],
          serviceRequestId: offer['serviceRequestId'],
        ),
      ),
    );
  }

  void _showConfirmDialog({
    required bool isAccept,
    required String name,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isAccept ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isAccept
                  ? Color(AppColors.primaryColor)
                  : Colors.redAccent,
            ),
            const SizedBox(width: 8),
            Text(
              isAccept ? "قبول العرض" : "رفض العرض",
              style: TextStyle(
                color: isAccept
                    ? Color(AppColors.primaryColor)
                    : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          isAccept
              ? "هل أنت متأكد من قبول عرض $name؟"
              : "هل أنت متأكد من رفض عرض $name؟",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "إلغاء",
              style: TextStyle(color: Color(AppColors.secondaryColor)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccept
                  ? Color(AppColors.primaryColor)
                  : Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("تأكيد", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: "جديدة (${_pendingOffers.length})"),
                Tab(text: "قيد التنفيذ (${_acceptedOffers.length})"),
                Tab(text: "مكتملة (${_completedOffers.length})"),
                Tab(text: "ملغية (${_rejectedOffers.length})"),
              ],
            ),
          ),

          // TabBar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOffersList(_pendingOffers, showActions: true),
                _buildOffersList(
                  _acceptedOffers,
                  showActions: false,
                  isAccepted: true,
                ),
                _buildOffersList(
                  _completedOffers,
                  showActions: false,
                  isCompleted: true,
                ),
                _buildOffersList(_rejectedOffers, showActions: false),
              ],
            ),
          ),
        ],
      ),
    );
  }


Widget _buildOffersList(List<Map<String, dynamic>> offers, {
  bool showActions = true,
  bool isAccepted = false,
  bool isCompleted = false,
}) {
  if (offers.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            isAccepted ? "لا توجد خدمات قيد التنفيذ" 
                       : (isCompleted ? "لا توجد خدمات مكتملة" : "لا توجد عروض"),
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }

  return ListView.builder(
    controller: widget.scrollController,
    padding: const EdgeInsets.all(16),
    itemCount: offers.length,
    itemBuilder: (context, index) {
      final offer = offers[index];
      return OfferCard(
        offer: offer,
        onAccept: showActions ? () => _acceptOffer(offer) : () {},
        onReject: showActions ? () => _rejectOffer(offer) : () {},
        onTrack: isAccepted ? () => _trackService(offer) : () {},
        // ✅ للخدمات المكتملة، مفيش أي callback (الزر مش هيظهر أصلاً)
      );
    },
  );
}

}
