// lib/features/home/screens/PagesView/provider_dashboard/widgets/offer_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:herafy/core/components/snack_bar_helper.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class OfferDialog extends StatefulWidget {
  const OfferDialog({super.key, required this.serviceName});

  final String serviceName;

  @override
  State<OfferDialog> createState() => _OfferDialogState();
}

class _OfferDialogState extends State<OfferDialog> {
  final _priceController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // تعبئة السعر تلقائياً بميزانية الطلب
  }

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(AppColors.primaryColor).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.payment_outlined,
                    color: Color(AppColors.primaryColor),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "تقديم عرض سعر",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.primaryColor),
                        ),
                      ),
                      Text(
                        "خدمة ${widget.serviceName}",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // حقل السعر
            Text(
              "السعر المطلوب",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: "أدخل السعر",
                suffixText: "ج.م",
                filled: true,
                fillColor: Color(AppColors.cardsColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.attach_money, color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 16),

            // حقل الرسالة
            Text(
              "رسالتك للعميل",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "اكتب تفاصيل عرضك...",
                filled: true,
                fillColor: Color(AppColors.cardsColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // أزرار
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      "إلغاء",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    // في زر "إرسال العرض"
                    onPressed: () {
                      final price = double.tryParse(_priceController.text);
                      if (price == null || price <= 0) {
                        SnackBarHelper.showWarningSnackBar(context, "من فضلك أدخل سعر صحيح");
                        return;
                      }
                      if (_messageController.text.trim().isEmpty) {
                        SnackBarHelper.showWarningSnackBar(context, "من فضلك اكتب رسالة لعرضك");
                        return;
                      }
                      // ✅ أضف هذا السطر
                      Navigator.pop(context, {
                        'price': price,
                        'message': _messageController.text.trim(),
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "إرسال العرض",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
