// lib/features/home/screens/PagesView/provider_dashboard/widgets/request_card.dart
import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/models/service_request_model.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    required this.onOffer,
    required this.onMapPressed,
  });

  final ServiceRequestModel request;
  final VoidCallback onOffer;
  final VoidCallback onMapPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildClientAvatar(),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRequestInfo()),
                    _buildTimeAgo(),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  request.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(AppColors.secondaryColor).withOpacity(0.8),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                _buildCardFooter(),
              ],
            ),
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildClientAvatar() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(AppColors.primaryColor).withOpacity(0.2),
        ),
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Color(AppColors.cardsColor),
        child: Icon(
          Icons.person_outline,
          color: Color(AppColors.primaryColor),
        ),
      ),
    );
  }

  Widget _buildRequestInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              request.clientName ?? "عميل",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (request.isUrgent) ...[
              const SizedBox(width: 8),
              _buildUrgentBadge(),
            ],
            const SizedBox(width: 8),
            _buildStatusBadge(),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(
              request.locationAddress,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String text;

    switch (request.status) {
      case 'Pending':
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange;
        text = "قيد الانتظار";
        break;
      case 'Assigned':
        bgColor = Colors.blue[50]!;
        textColor = Colors.blue;
        text = "تم التخصيص";
        break;
      case 'InProgress':
        bgColor = Colors.green[50]!;
        textColor = Colors.green;
        text = "قيد التنفيذ";
        break;
      case 'Completed':
        bgColor = Colors.teal[50]!;
        textColor = Colors.teal;
        text = "مكتمل";
        break;
      case 'Cancelled':
        bgColor = Colors.red[50]!;
        textColor = Colors.red;
        text = "ملغي";
        break;
      default:
        bgColor = Colors.grey[50]!;
        textColor = Colors.grey;
        text = request.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUrgentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        "عاجل",
        style: TextStyle(
          color: Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeAgo() {
    // حساب الوقت المنقضي (مؤقت)
    final createdAt = DateTime.tryParse(request.createdAt);
    String timeAgo = "منذ قليل";
    if (createdAt != null) {
      final diff = DateTime.now().difference(createdAt);
      if (diff.inMinutes < 60) {
        timeAgo = "منذ ${diff.inMinutes} دقائق";
      } else if (diff.inHours < 24) {
        timeAgo = "منذ ${diff.inHours} ساعات";
      } else {
        timeAgo = "منذ ${diff.inDays} أيام";
      }
    }
    return Text(
      timeAgo,
      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
    );
  }

  Widget _buildCardFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTag(Icons.category_outlined, request.serviceName),
        Text(
          "${request.budget.toStringAsFixed(0)} ج.م",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF43C59E),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(AppColors.cardsColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Color(AppColors.primaryColor)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(AppColors.primaryColor),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildActionButtons(BuildContext context) {
  // إذا كان الطلب مكتمل أو ملغي، مفيش أزرار
  if (request.status == 'Completed' || request.status == 'Cancelled') {
    return const SizedBox.shrink();
  }

  // إذا كان الطلب في حالة Assigned (عروض مرسلة)
  if (request.status == 'Assigned') {
    // هنفترض إن فيه عرض pending، لو اتقبل هتتغير الحالة
    // مؤقتاً هنستخدم isAccepted متغير وهمي
    final bool isOfferAccepted = false; // هتتيجي من API بعدين
    final bool isOfferRejected = false; // هتتيجي من API بعدين
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // حالة العرض
            if (isOfferAccepted)
              _buildAcceptedOfferBadge()
            else if (isOfferRejected)
              _buildRejectedOfferBadge()
            else
              _buildPendingOfferBadge(),
            
            // زرار الخريطة
            TextButton.icon(
              onPressed: onMapPressed,
              icon: Icon(Icons.map_outlined, size: 18, color: Color(AppColors.primaryColor)),
              label: Text(
                "على الخريطة",
                style: TextStyle(color: Color(AppColors.primaryColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // الطلبات الجديدة (Pending)
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: onMapPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  "على الخريطة",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        Container(width: 1, height: 20, color: Colors.grey[200]),
        Expanded(
          child: TextButton(
            onPressed: onOffer,
            child: Text(
              "تقديم عرض",
              style: TextStyle(
                color: Color(AppColors.primaryColor),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// عرض حالة العرض (قيد الانتظار)
Widget _buildPendingOfferBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.orange[50],
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.orange.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          "في انتظار قبول العميل",
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// عرض حالة العرض (مقبول)
Widget _buildAcceptedOfferBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.green[50],
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.green.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 14),
        const SizedBox(width: 8),
        const Text(
          "تم قبول عرضك - قيد التنفيذ",
          style: TextStyle(
            fontSize: 12,
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// عرض حالة العرض (مرفوض)
Widget _buildRejectedOfferBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.red[50],
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.red.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cancel, color: Colors.red, size: 14),
        const SizedBox(width: 8),
        const Text(
          "لم يقبل العميل عرضك",
          style: TextStyle(
            fontSize: 12,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
// إضافة دالة جديدة لعرض حالة العرض
Widget _buildOfferStatusBadge() {
  // مؤقتاً هنفترض إن العرض لسةPending (هتتغير لما نربط API)
  // لو العرض Accepted أو Rejected هتظهر مختلفة
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.orange[50],
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.orange.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          "في انتظار قبول العميل",
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

}