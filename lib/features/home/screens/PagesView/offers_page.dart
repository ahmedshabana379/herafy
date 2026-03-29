import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/widgets/offer_card.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key, this.scrollController});
  final ScrollController? scrollController;

  // mock data مؤقتة
  static const List<Map<String, dynamic>> _mockOffers = [
    {
      "name": "أحمد السباك",
      "job": "سباك محترف",
      "price": 350,
      "description": "هقوم بإصلاح التسريب وتغيير الوصلات القديمة باحترافية",
      "rating": 4.8,
      "completedJobs": 120,
    },
    {
      "name": "محمد علي",
      "job": "سباك معتمد",
      "price": 280,
      "description": null,
      "rating": 4.5,
      "completedJobs": 85,
    },
    {
      "name": "كريم حسن",
      "job": "فني صرف صحي",
      "price": 400,
      "description": "خبرة 10 سنين في الصرف والمواسير مع ضمان على الشغل",
      "rating": 4.9,
      "completedJobs": 200,
    },
    {
      "name": "طارق محمود",
      "job": "سباك",
      "price": 200,
      "description": null,
      "rating": 4.2,
      "completedJobs": 45,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return _mockOffers.isEmpty
        ? Center(
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
                  "مفيش عروض لحد دلوقتي",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                ),
              ],
            ),
          )
        : ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _mockOffers.length,
            itemBuilder: (context, index) {
              return OfferCard(offer: _mockOffers[index]);
            },
          );
  }
}
