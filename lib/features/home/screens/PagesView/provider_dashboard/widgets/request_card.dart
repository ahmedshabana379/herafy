// lib/features/home/screens/PagesView/provider_dashboard/widgets/request_card.dart
import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/models/request_offer_model.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/models/request_model.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    required this.onOffer,
    required this.onMapPressed,
    this.myOffer,
  });
  final RequestOfferModel? myOffer;
  final ServiceRequestModelProvider request;
  final VoidCallback onOffer;
  final VoidCallback onMapPressed;

  String get _timeAgo {
    final createdAt = DateTime.tryParse(request.createdAt);
    if (createdAt == null) return "منذ قليل";
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) {
      return "منذ ${diff.inMinutes} دقائق";
    } else if (diff.inHours < 24) {
      return "منذ ${diff.inHours} ساعات";
    } else {
      return "منذ ${diff.inDays} أيام";
    }
  }

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
        child: Icon(Icons.person_outline, color: Color(AppColors.primaryColor)),
      ),
    );
  }

  Widget _buildRequestInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                request.clientName ?? "عميل",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (request.isUrgent) ...[
              const SizedBox(width: 4),
              _buildUrgentBadge(),
            ],
            const SizedBox(width: 4),
            _buildStatusBadge(),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                "موقع العميل",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
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

    switch (request.requestStatus) {
      case 0:
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange;
        text = "قيد الانتظار";
        break;
      case 1:
        bgColor = Colors.blue[50]!;
        textColor = Colors.blue;
        text = "تم التخصيص";
        break;
      case 2:
        bgColor = Colors.green[50]!;
        textColor = Colors.green;
        text = "قيد التنفيذ";
        break;
      case 3:
        bgColor = Colors.teal[50]!;
        textColor = Colors.teal;
        text = "مكتمل";
        break;
      case 4:
        bgColor = Colors.red[50]!;
        textColor = Colors.red;
        text = "ملغي";
        break;
      default:
        bgColor = Colors.grey[50]!;
        textColor = Colors.grey;
        text = "غير معروف";
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
    return Text(
      _timeAgo,
      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
    );
  }

  Widget _buildCardFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTag(Icons.category_outlined, "طلب خدمة"),
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
    if (request.requestStatus == 3 || request.requestStatus == 4) {
      return const SizedBox.shrink();
    }

    if (request.requestStatus == 1) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPendingOfferBadge(),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onMapPressed,
                icon: Icon(
                  Icons.map_outlined,
                  size: 18,
                  color: Color(AppColors.primaryColor),
                ),
                label: Text(
                  "على الخريطة",
                  style: TextStyle(
                    color: Color(AppColors.primaryColor),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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

  Widget _buildPendingOfferBadge() {
    if (myOffer == null) {
      return const SizedBox.shrink();
    }
    // لون ومحتوى بناءً على status العرض
    Color color;
    String text;
    IconData icon;

    switch (myOffer?.status) {
      case 'Accepted':
        color = Colors.green;
        text = "تم قبول عرضك ✓";
        icon = Icons.check_circle_outline;
        break;
      case 'Rejected':
        color = Colors.red;
        text = "تم رفض عرضك";
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.orange;
        text = "في انتظار قبول العميل";
        icon = Icons.hourglass_empty;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // سعر العرض
        if (myOffer != null)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${myOffer!.price.toStringAsFixed(0)} ج.م",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        // status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
