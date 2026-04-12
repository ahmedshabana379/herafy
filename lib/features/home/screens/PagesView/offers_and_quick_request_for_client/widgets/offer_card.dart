// lib/features/home/screens/PagesView/offers_and_quick_request_for_client/widgets/offer_card.dart
import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.onAccept,
    required this.onReject,
    required this.onTrack, // جديد: لمتابعة الخدمة بعد القبول
  });

  final Map<String, dynamic> offer;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onTrack;

  @override
  Widget build(BuildContext context) {
    final status = offer['status'] ?? 'pending'; // pending, accepted, completed, rejected
    
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
              children: [
                // صورة مقدم الخدمة
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(AppColors.cardsColor),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Color(AppColors.primaryColor),
                  ),
                ),
                const SizedBox(width: 12),

                // الاسم والمهنة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            offer["name"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        offer["job"],
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(AppColors.secondaryColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // الريتينج والشغل المنجز
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            "${offer["rating"]}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: Color(AppColors.primaryColor),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            "${offer["completedJobs"]} مهمة",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(AppColors.secondaryColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // السعر
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'accepted' 
                        ? Colors.green 
                        : (status == 'rejected' 
                            ? Colors.red 
                            : Color(AppColors.primaryColor)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${offer["price"]} ج.م",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // الديسكريبشن لو موجود
          if (offer["description"] != null && offer["description"].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(AppColors.cardsColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  offer["description"],
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(AppColors.secondaryColor),
                    height: 1.5,
                  ),
                ),
              ),
            ),

          // الأزرار (تختلف حسب الحالة)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: _buildButtons(status),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

 // في OfferCard - تعديل _buildButtons

Widget _buildButtons(String status) {
  if (status == 'accepted') {
    // عرض زر "متابعة الخدمة"
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
    // ✅ بدل زر التقييم، نعرض نص "تم التقييم" أو "مكتمل"
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          "✅ تم إكمال الخدمة",
          style: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.w500),
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
          style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
  
  // pending - أزرار قبول ورفض
  return Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: onReject,
          icon: const Icon(Icons.close, size: 16),
          label: const Text("رفض"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton.icon(
          onPressed: onAccept,
          icon: const Icon(Icons.check, size: 16),
          label: const Text("قبول"),
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

}