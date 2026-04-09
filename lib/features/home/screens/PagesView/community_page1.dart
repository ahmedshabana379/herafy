import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/features/home/cubits/cubit/posts_and_comments_cubit.dart';
import 'package:herafy/features/home/cubits/cubit/posts_and_comments_state.dart';
import 'package:herafy/features/screens/widgets/post_card.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key, this.scrollController});
  final ScrollController? scrollController;

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

      widget.scrollController?.addListener(_onScroll);
    } catch (_) {
      _socialCubit = null;
    }
  }

  void _onScroll() {
    final sc = widget.scrollController;
    if (sc == null) return;
    if (sc.position.pixels >= sc.position.maxScrollExtent - 200) {
      _socialCubit?.loadMorePosts();
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_socialCubit == null) {
      return _buildPostsListFromMock();
    }

    return BlocBuilder<SocialCubit, SocialState>(
      bloc: _socialCubit,
      builder: (context, state) {
        if (state is GetPostsLoading) {
          return _buildLoadingSkeleton();
        }

        if (state is GetPostsError) {
          return _buildPostsListFromMock();
        }

        if (_socialCubit!.posts.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _socialCubit!.posts.length,
              itemBuilder: (context, index) {
                final post = _socialCubit!.posts[index];
                final hasImage = post.imageUrls.isNotEmpty;

                // تحويل الـ createdAt لوقت مقروء
                String timeAgo = "";
                if (post.createdAt != null) {
                  final created = DateTime.tryParse(post.createdAt!);
                  if (created != null) {
                    final diff = DateTime.now().difference(created);
                    if (diff.inMinutes < 60) {
                      timeAgo = "منذ ${diff.inMinutes} دقيقة";
                    } else if (diff.inHours < 24) {
                      timeAgo = "منذ ${diff.inHours} ساعة";
                    } else {
                      timeAgo = "منذ ${diff.inDays} يوم";
                    }
                  }
                }

                // الصورة - لو مسارها relative نضيف الـ base URL
                const baseUrl = "https://iti-final-project.runasp.net/";
                final imageUrl = hasImage
                    ? "$baseUrl${post.imageUrls.first}"
                    : "";
                final avatarUrl = post.clientPictureUrl != null
                    ? "$baseUrl${post.clientPictureUrl}"
                    : "";

                return PostCard(
                  postId: post.id,
                  providerName: post.clientName ?? "مستخدم",
                  providerJob: post.isProvider ? "مزود خدمة" : "عميل",
                  timeAgo: timeAgo,
                  description: post.description ?? post.title,
                  imageUrl: imageUrl,
                  avatarUrl: avatarUrl, // ← جديد
                  likesCount: 0,
                  commentsCount: post.commentsCount,
                  isServiceOffer: post.isProvider,
                );
              },
            ),
          );
        }

        // مفيش posts خالص - مش mock
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              "لا توجد منشورات بعد\nكن أول من ينشر!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsListFromMock() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: BlocBuilder<SocialCubit, SocialState>(
        bloc: _socialCubit,
        buildWhen: (_, state) => state is GetPostsLoadingMore,
        builder: (context, loadMoreState) {
          return ListView.builder(
            controller: widget.scrollController,
            itemCount: _socialCubit!.posts.length + 1,
            itemBuilder: (context, index) {
              if (index == _socialCubit!.posts.length) {
                if (loadMoreState is GetPostsLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return const SizedBox.shrink();
              }

              final post = _socialCubit!.posts[index];
              final hasImage = post.imageUrls.isNotEmpty;
              const baseUrl = "https://iti-final-project.runasp.net/";

              String timeAgo = "";
              if (post.createdAt != null) {
                final created = DateTime.tryParse(post.createdAt!);
                if (created != null) {
                  final diff = DateTime.now().difference(created);
                  if (diff.inMinutes < 60) {
                    timeAgo = "منذ ${diff.inMinutes} دقيقة";
                  } else if (diff.inHours < 24) {
                    timeAgo = "منذ ${diff.inHours} ساعة";
                  } else {
                    timeAgo = "منذ ${diff.inDays} يوم";
                  }
                }
              }

              final imageUrl = hasImage ? post.imageUrls.first : "";
              final avatarUrl = post.clientPictureUrl != null
                  ? "${post.clientPictureUrl}"
                  : "";

              return PostCard(
                postId: post.id,
                providerName: post.clientName ?? "مستخدم",
                providerJob: post.isProvider ? "مزود خدمة" : "عميل",
                timeAgo: timeAgo,
                description: post.description ?? post.title,
                imageUrl: imageUrl,
                avatarUrl: avatarUrl,
                likesCount: 0,
                commentsCount: post.commentsCount,
                isServiceOffer: post.isProvider,
              );
            },
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
