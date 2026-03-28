import 'package:flutter/material.dart';
import 'package:herafy/features/home/widgets/post_card.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  // داتا وهمية للتجربة
  static const List<Map<String, dynamic>> _mockPosts = [
    {
      "isServiceOffer": false,
      "name": "أحمد السباك",
      "job": "سباك محترف",
      "time": "منذ ساعتين",
      "desc":
          "تم إصلاح تسريب مياه في شقة بالمهندسين، استبدال كامل لمواسير الحمام",
      "image": "https://picsum.photos/seed/1/400/300",
      "likes": 24,
      "comments": 5,
    },
    {
      "isServiceOffer": false,
      "name": "محمد الكهربائي",
      "job": "كهربائي معتمد",
      "time": "منذ 3 ساعات",
      "desc":
          "تركيب لوحة كهربائية جديدة مع أحدث معايير الأمان للحماية من الحرائق",
      "image": "https://picsum.photos/seed/2/400/300",
      "likes": 41,
      "comments": 12,
    },
    {
      "isServiceOffer": true,
      "name": "كريم النجار",
      "job": "نجار ديكور",
      "time": "منذ 5 ساعات",
      "desc": "تصميم وتنفيذ مطبخ خشبي كامل بأحدث الخامات الإيطالية",
      "image": "https://picsum.photos/seed/3/400/300",
      "likes": 89,
      "comments": 23,
    },
    {
      "isServiceOffer": true,
      "name": "سامي المقاول",
      "job": "مقاول بناء",
      "time": "منذ 6 ساعات",
      "desc": "إعادة تشطيب شقة 150 متر في الزمالك خلال 3 أسابيع فقط",
      "image": "https://picsum.photos/seed/4/400/300",
      "likes": 56,
      "comments": 8,
    },
    {
      "isServiceOffer": false,
      "name": "طارق فني التكييف",
      "job": "فني تكييف",
      "time": "منذ 8 ساعات",
      "desc": "صيانة وغاز 5 تكييفات في فيلا بالشيخ زايد، خصم خاص للعملاء الجدد",
      "image": "https://picsum.photos/seed/5/400/300",
      "likes": 33,
      "comments": 7,
    },
    {
      "isServiceOffer": true,
      "name": "علي الدهان",
      "job": "نقاش محترف",
      "time": "منذ 10 ساعات",
      "desc":
          "دهان فيلا كاملة بتقنية الجرانيت الإيطالي، النتيجة تتكلم عن نفسها",
      "image": "https://picsum.photos/seed/6/400/300",
      "likes": 102,
      "comments": 31,
    },
    {
      "isServiceOffer": true,
      "name": "حسن الحداد",
      "job": "حداد فني",
      "time": "منذ 12 ساعة",
      "desc": "تصنيع وتركيب بوابة حديدية أمنية بتصميم مودرن لفيلا في التجمع",
      "image": "https://picsum.photos/seed/7/400/300",
      "likes": 67,
      "comments": 14,
    },
    {
      "isServiceOffer": true,
      "name": "مصطفى فني السيراميك",
      "job": "فني سيراميك",
      "time": "أمس",
      "desc":
          "تركيب سيراميك باركيه في صالة 80 متر، دقة في التشطيب بدون أي فواصل",
      "image": "https://picsum.photos/seed/8/400/300",
      "likes": 78,
      "comments": 19,
    },
    {
      "isServiceOffer": true,
      "name": "يوسف فني الجبس",
      "job": "فني جبس بورد",
      "time": "أمس",
      "desc": "تنفيذ أسقف جبس بورد بإضاءة LED مخفية لشقة في مدينة نصر",
      "image": "https://picsum.photos/seed/9/400/300",
      "likes": 95,
      "comments": 27,
    },
    {
      "isServiceOffer": false,
      "name": "إبراهيم فني الألمونيوم",
      "job": "فني ألمونيوم",
      "time": "منذ يومين",
      "desc": "تركيب واجهة ألمونيوم كاملة لعمارة سكنية في مصر الجديدة",
      "image": "https://picsum.photos/seed/10/400/300",
      "likes": 113,
      "comments": 42,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _mockPosts.length,
      itemBuilder: (context, index) {
        final post = _mockPosts[index];
        return PostCard(
          providerName: post["name"],
          providerJob: post["job"],
          timeAgo: post["time"],
          description: post["desc"],
          imageUrl: post["image"],
          likesCount: post["likes"],
          commentsCount: post["comments"],
          isServiceOffer: post["isServiceOffer"] ?? false,
        );
      },
    );
  }
}
