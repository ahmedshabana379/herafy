// lib/features/home/screens/PagesView/offers_and_quick_request_for_client/widgets/offer_card.dart
import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.onAccept,
    required this.onReject,
    required this.onTrack,
  });

  final Map<String, dynamic> offer;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onTrack;

  @override
  Widget build(BuildContext context) {
    final status = offer['status'] ?? 'pending';

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
          // هيدر الكارد
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة مقدم الخدمة
                _buildProviderImage(),
                const SizedBox(width: 12),

                // الاسم والرسالة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              offer["name"] ?? "حرفي",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // لـ:
                          if (status == 'pending')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${offer['price']} ج.م",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          else
                            _buildStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // رسالة الحرفي
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          offer["message"] ?? "لا توجد رسالة",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // السعر والأزرار
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [const SizedBox(height: 12), _buildButtons(status)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderImage() {
    final imageUrl = offer['providerPictureUrl'];

    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(
          'https://iti-final-project.runasp.net/$imageUrl',
        ),
        onBackgroundImageError: (_, __) => _buildDefaultAvatar(),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Color(AppColors.cardsColor),
      child: Icon(Icons.person, size: 30, color: Color(AppColors.primaryColor)),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 'accepted':
        bgColor = Colors.green[50]!;
        textColor = Colors.green;
        text = "مقبول";
        break;
      case 'completed':
        bgColor = Colors.teal[50]!;
        textColor = Colors.teal;
        text = "مكتمل";
        break;
      case 'rejected':
        bgColor = Colors.red[50]!;
        textColor = Colors.red;
        text = "مرفوض";
        break;
      default:
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange;
        text = "قيد الانتظار";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildButtons(String status) {
    if (status == 'accepted') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onTrack,
              icon: const Icon(Icons.track_changes, size: 18),
              label: const Text("متابعة الخدمة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.primaryColor),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    }

    if (status == 'completed') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.teal[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "✅ تم إكمال الخدمة",
            style: TextStyle(
              color: Colors.teal[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    if (status == 'rejected') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "❌ تم رفض هذا العرض",
            style: TextStyle(
              color: Colors.red[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // pending - زرار قبول بس
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAccept,
        icon: const Icon(Icons.check, size: 16),
        label: const Text("قبول العرض"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppColors.primaryColor),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
