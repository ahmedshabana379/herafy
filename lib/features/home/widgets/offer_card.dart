import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer});
  final Map<String, dynamic> offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                      Text(
                        offer["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
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
                            color: Colors.amber,
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
                            "${offer["completedJobs"]} مهمة منجزة",
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
                    color: Color(AppColors.primaryColor),
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
          if (offer["description"] != null)
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
          Container(
            margin: const EdgeInsets.all(16),

            height: 120,
            decoration: BoxDecoration(
              color: Color(AppColors.cardsColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Color(AppColors.primaryColor),
                    size: 30,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "الموقع سيظهر هنا",
                    style: TextStyle(color: Color(AppColors.secondaryColor)),
                  ),
                ],
              ),
            ),
          ),
          // الأزرار
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // رفض
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showConfirmDialog(
                      context,
                      isAccept: false,
                      name: offer["name"],
                    ),
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

                // قبول
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showConfirmDialog(
                      context,
                      isAccept: true,
                      name: offer["name"],
                    ),
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
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required bool isAccept,
    required String name,
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
              // هنا هتكالل الـ API بعدين
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccept
                  ? Color(AppColors.primaryColor)
                  : Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("تأكيد", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
