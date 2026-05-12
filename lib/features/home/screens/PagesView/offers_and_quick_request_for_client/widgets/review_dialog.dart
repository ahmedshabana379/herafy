// lib/features/home/screens/PagesView/offers_and_quick_request_for_client/widgets/review_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:herafy/core/components/snack_bar_helper.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class ReviewDialog extends StatefulWidget {
  const ReviewDialog({
    super.key,
    required this.providerName,
    required this.serviceType,
    // required this.agreedPrice,
    required this.onReviewSubmitted,
  });

  final String providerName;
  final String serviceType;
  // final double agreedPrice;
  final Function(double rating, String comment) onReviewSubmitted; // DELETED: Removed paidAmount parameter

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  double _rating = 0;
  String _comment = '';
  // DELETED: Removed paid amount controller
  // final TextEditingController _paidAmountController = TextEditingController();
  // String? _amountError;

  @override
  void initState() {
    super.initState();
    // DELETED: Removed paid amount controller initialization
    // _paidAmountController.text = widget.agreedPrice.toStringAsFixed(0);
  }

  @override
  void dispose() {
    // DELETED: Removed paid amount controller disposal
    // _paidAmountController.dispose();
    super.dispose();
  }

  // DELETED: Removed amount validation method
  // void _validateAmount() {
  //   final amount = double.tryParse(_paidAmountController.text);
  //   if (amount == null || amount <= 0) {
  //     setState(() {
  //       _amountError = "من فضلك أدخل مبلغ صحيح";
  //     });
  //   } else if (amount > widget.agreedPrice + 100) {
  //     setState(() {
  //       _amountError = "المبلغ أكبر من المتوقع بكثير";
  //     });
  //   } else {
  //     setState(() {
  //       _amountError = null;
  //     });
  //   }
  // }

  void _submitReview() {
    if (_rating == 0) {
      SnackBarHelper.showWarningSnackBar(context, "من فضلك قيم الخدمة");
      return;
    }

    // DELETED: Removed paid amount validation
    // final paidAmount = double.tryParse(_paidAmountController.text);
    // if (paidAmount == null || paidAmount <= 0) {
    //   SnackBarHelper.showWarningSnackBar(context, "من فضلك أدخل المبلغ المدفوع");
    //   return;
    // }

    // أغلق الدايالوج أولاً ثم استدع الكال باك
    Navigator.pop(context);
    widget.onReviewSubmitted(_rating, _comment); // DELETED: Removed paidAmount parameter
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
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star_rate_rounded, color: Colors.amber[700], size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "تقييم الخدمة",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.primaryColor),
                        ),
                      ),
                      Text(
                        "${widget.providerName} - ${widget.serviceType}",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Rating Stars
            Center(
              child: Column(
                children: [
                  const Text(
                    "تقييمك للحرفي",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // DELETED: Removed entire Paid Amount Field section
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: Color(AppColors.cardsColor),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Row(
            //         children: [
            //           Icon(Icons.attach_money, size: 18, color: Color(AppColors.primaryColor)),
            //           const SizedBox(width: 6),
            //           Text(
            //             "المبلغ المدفوع للحرفي",
            //             style: TextStyle(
            //               fontSize: 13,
            //               fontWeight: FontWeight.w500,
            //               color: Color(AppColors.primaryColor),
            //             ),
            //           ),
            //           const SizedBox(width: 4),
            //           Text(
            //             "*",
            //             style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            //           ),
            //         ],
            //       ),
            //       const SizedBox(height: 8),
            //       TextField(
            //         controller: _paidAmountController,
            //         keyboardType: TextInputType.number,
            //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            //         onChanged: (_) => _validateAmount(),
            //         decoration: InputDecoration(
            //           hintText: "المبلغ اللي دفعته",
            //           suffixText: "ج.م",
            //           filled: true,
            //           fillColor: Colors.white,
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(10),
            //             borderSide: BorderSide.none,
            //           ),
            //           errorText: _amountError,
            //           errorStyle: const TextStyle(fontSize: 10),
            //         ),
            //       ),
            //       const SizedBox(height: 8),
            //       Text(
            //         "المبلغ المتفق عليه: ${widget.agreedPrice.toStringAsFixed(0)} ج.م",
            //         style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 16),
            
            // Comment Field
            TextField(
              maxLines: 3,
              onChanged: (value) => _comment = value,
              decoration: InputDecoration(
                hintText: "شاركنا رأيك في الخدمة (اختياري)",
                filled: true,
                fillColor: Color(AppColors.cardsColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Buttons
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
                    ),
                    child: Text("تخطي", style: TextStyle(color: Colors.grey[600])),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("إرسال التقييم", style: TextStyle(color: Colors.white)),
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