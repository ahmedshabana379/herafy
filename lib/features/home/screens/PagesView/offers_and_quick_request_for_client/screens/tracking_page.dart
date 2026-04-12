// lib/features/home/screens/PagesView/offers_and_quick_request_for_client/tracking_page.dart
import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/screens/PagesView/offers_and_quick_request_for_client/widgets/review_dialog.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({
    super.key,
    required this.providerName,
    required this.serviceType,
    required this.price,
    required this.providerId,
    required this.serviceRequestId,
  });

  final String providerName;
  final String serviceType;
  final double price;
  final String providerId;
  final String serviceRequestId;

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  double _providerLatitude = 30.0444;
  double _providerLongitude = 31.2357;
  String _status = "completed"; // تغيير لـ completed عشان يظهر الزر
  String _statusText = "الحرفي في الطريق إليك";

  final List<Map<String, dynamic>> _steps = [
    {"label": "تم قبول العرض", "time": "10:30", "completed": true},
    {"label": "الحرفي في الطريق", "time": "الآن", "completed": true},
    {"label": "بدأ العمل", "time": "11:00", "completed": true},
    {
      "label": "تم الانتهاء",
      "time": "12:30",
      "completed": true,
    }, // كلها completed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("متابعة الخدمة - ${widget.serviceType}"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        // ✅ إضافة SingleChildScrollView
        child: Column(
          children: [
            // خريطة
            Container(
              height: 220,
              width: double.infinity,
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 50,
                      color: Color(AppColors.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "خريطة موقع الحرفي",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "الإحداثيات: $_providerLatitude, $_providerLongitude",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),

            // معلومات الحرفي
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(AppColors.cardsColor),
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Color(AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.providerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.serviceType,
                          style: TextStyle(
                            color: Color(AppColors.secondaryColor),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      "${widget.price} ج.م",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Timeline
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timeline,
                        size: 20,
                        color: Color(AppColors.primaryColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "حالة الخدمة",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    final isLast = index == _steps.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Column(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: step['completed']
                                      ? Color(AppColors.primaryColor)
                                      : Colors.grey[300],
                                ),
                                child: step['completed']
                                    ? const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: step['completed']
                                      ? Color(AppColors.primaryColor)
                                      : Colors.grey[300],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step['label'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: step['completed']
                                        ? Colors.black
                                        : Colors.grey[500],
                                  ),
                                ),
                                if (step['time'].toString().isNotEmpty)
                                  Text(
                                    step['time'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // زر تم الاستلام
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _status == "completed"
                      ? () => _showCompletionDialog()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.primaryColor),
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _status == "completed"
                        ? "تم الاستلام والتقييم"
                        : "الخدمة قيد التنفيذ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

 // في TrackingPage - تعديل _showCompletionDialog

void _showCompletionDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ReviewDialog(
      providerName: widget.providerName,
      serviceType: widget.serviceType,
      agreedPrice: widget.price,
      onReviewSubmitted: (rating, comment, paidAmount) {
        print("تم التقييم: $rating نجوم, المبلغ: $paidAmount");
        
        // نغلق TrackingPage ونرجع لـ OffersPage
        Navigator.pop(context); // إغلاق الـ Dialog
        Navigator.pop(context); // إغلاق TrackingPage
        
        // نعرض رسالة تأكيد
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("شكراً لتقييمك، سيتم تحديث حالة الخدمة"),
            backgroundColor: Colors.green,
          ),
        );
        
        // هنا بعدين هنحدث حالة الطلب في الـ API
        // ونحركه من "قيد التنفيذ" إلى "مكتمل"
      },
    ),
  );
}
}
