import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/features/home/cubits/cubit/posts_and_comments_cubit.dart';
import 'package:herafy/features/home/cubits/cubit/posts_and_comments_state.dart';
import 'package:herafy/features/screens/widgets/post_card.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key, this.scrollController});
  final ScrollController? scrollController;
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
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with AutomaticKeepAliveClientMixin {
  SocialCubit? _socialCubit;

  @override
  void initState() {
    super.initState();
    try {
      _socialCubit = BlocProvider.of<SocialCubit>(context);
      _socialCubit!.getPosts();
    } catch (_) {
      _socialCubit = null;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // ← مهم

    if (_socialCubit == null) {
      return _buildPostsListFromMock();
    }

    return BlocBuilder<SocialCubit, SocialState>(
      bloc: _socialCubit,
      builder: (context, state) {
        if (state is GetPostsLoading) {
          return _buildLoadingSkeleton();
        }

        if (_socialCubit!.posts.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _socialCubit!.posts.length,
              itemBuilder: (context, index) {
                final post = _socialCubit!.posts[index];
                return PostCard(
                  postId: post.id,
                  providerName: "Service Provider",
                  providerJob: "Herafy",
                  timeAgo: "Just now",
                  description: post.description ?? post.title,
                  imageUrl: (post.images != null && post.images!.isNotEmpty)
                      ? post.images!.first
                      : "https://picsum.photos/seed/post_${post.id}/400/300",
                  likesCount: post.reactionsCount,
                  commentsCount: 0,
                  isServiceOffer: false,
                );
              },
            ),
          );
        }

        return _buildPostsListFromMock();
      },
    );
  }

  Widget _buildPostsListFromMock() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: CommunityPage._mockPosts.length,
        itemBuilder: (context, index) {
          final post = CommunityPage._mockPosts[index];
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
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: 4,
        itemBuilder: (context, index) => const _PostSkeletonCard(),
      ),
    );
  }
}

class _PostSkeletonCard extends StatelessWidget {
  const _PostSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _ShimmerBox(width: 40, height: 40, radius: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ShimmerBox(width: 120, height: 12),
                    const SizedBox(height: 8),
                    const _ShimmerBox(width: 90, height: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _ShimmerBox(width: double.infinity, height: 10),
          const SizedBox(height: 8),
          const _ShimmerBox(width: 180, height: 10),
          const SizedBox(height: 12),
          const _ShimmerBox(width: double.infinity, height: 220, radius: 8),
          const SizedBox(height: 12),
          Row(
            children: [
              const _ShimmerBox(width: 55, height: 10),
              const SizedBox(width: 24),
              const _ShimmerBox(width: 45, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width == double.infinity ? null : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + (2 * t), -0.3),
              end: Alignment(1 + (2 * t), 0.3),
              colors: const [
                Color(0xFFE9E9E9),
                Color(0xFFF5F5F5),
                Color(0xFFE9E9E9),
              ],
            ),
          ),
        );
      },
    );
  }
}
