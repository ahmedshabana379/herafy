import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/cubits/posts_comments/posts_and_comments_cubit.dart';
import 'package:herafy/features/screens/post_details_page.dart';

class PostCard extends StatefulWidget {
  final int postId;
  final String providerName,
      providerJob,
      timeAgo,
      description,
      imageUrl,
      avatarUrl;
  final int likesCount, commentsCount;
  final bool isServiceOffer;
  final List<dynamic> topReactions; // ← جديد
  final bool isReacted;
  final int? myReactionType;
  const PostCard({
    super.key,
    this.postId = 0,
    required this.providerName,
    required this.providerJob,
    required this.timeAgo,
    required this.description,
    required this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isServiceOffer = false,
    required this.avatarUrl,
    this.topReactions = const [],
    required this.isReacted,
    this.myReactionType,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  bool isSaved = false;
  int? myReaction; // null = no reaction
  late int likesCount;
  bool _showReactions = false; // ← لإظهار الـ reaction picker

  // الـ reactions المتاحة
  static const Map<int, String> reactionEmojis = {
    1: "👍",
    2: "❤️",
    3: "😂",
    4: "😡",
    5: "😢",
  };
  static const Map<int, String> reactionLabels = {
    1: "إعجاب",
    2: "حب",
    3: "ضحك",
    4: "غضب",
    5: "حزن",
  };
  static const Map<int, Color> reactionColors = {
    1: Colors.blue,
    2: Colors.red,
    3: Colors.amber,
    4: Colors.orange,
    5: Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    likesCount = widget.likesCount;
    myReaction = widget.myReactionType; // ← من السيرفر
    isLiked = widget.isReacted;
  }

  void _onReactionSelected(BuildContext context, int reaction) {
    setState(() {
      if (myReaction == reaction) {
        myReaction = null;
        likesCount--;
      } else {
        if (myReaction == null) likesCount++;
        myReaction = reaction;
      }
      _showReactions = false;
    });
    context.read<SocialCubit>().reactToPost(
      postId: widget.postId,
      reactionType: reaction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showReactions) {
          setState(() => _showReactions = false);
          return;
        }
       Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PostDetailsPage(
      post: widget,
      postId: widget.postId,
      isInitialLiked: myReaction != null,
      initialLikesCount: likesCount,
      initialReactionType: myReaction, // ← أضف
      onBack: (newLiked, newCount) {
        setState(() {
          isLiked = newLiked;
          likesCount = newCount;
        });
      },
    ),
  ),
);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildDescription(),
            _buildImage(),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(AppColors.cardsColor),
            backgroundImage: widget.avatarUrl.isNotEmpty
                ? NetworkImage(widget.avatarUrl)
                : null,
            onBackgroundImageError: widget.avatarUrl.isNotEmpty
                ? (_, __) {}
                : null,
            child: widget.avatarUrl.isEmpty
                ? Icon(Icons.person, color: Color(AppColors.primaryColor))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.providerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.verified,
                      size: 12,
                      color: Color(AppColors.primaryColor),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.providerJob,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(AppColors.secondaryColor),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "· ${widget.timeAgo}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.more_horiz, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (widget.imageUrl.isEmpty) return const SizedBox.shrink();
    return Hero(
      tag: widget.imageUrl,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Image.network(
          widget.imageUrl,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        widget.description,
        style: TextStyle(
          fontSize: 14,
          color: Color(AppColors.secondaryColor),
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final reactionEmoji = myReaction != null
        ? reactionEmojis[myReaction] ?? "👍"
        : null;
    final reactionColor = myReaction != null
        ? reactionColors[myReaction] ?? Colors.grey
        : Colors.grey.shade600;
    final reactionLabel = myReaction != null
        ? reactionLabels[myReaction] ?? "إعجاب"
        : "إعجاب";

    return Column(
      children: [
        // Reaction Picker
        if (_showReactions)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: reactionEmojis.entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _onReactionSelected(context, entry.key),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: [
              // زرار الـ reaction
              GestureDetector(
                onLongPress: () =>
                    setState(() => _showReactions = !_showReactions),
                onTap: () => myReaction == null
                    ? _onReactionSelected(context, 1) // like افتراضي
                    : _onReactionSelected(context, myReaction!),
                child: Row(
                  children: [
                    reactionEmoji != null
                        ? Text(
                            reactionEmoji,
                            style: const TextStyle(fontSize: 18),
                          )
                        : Icon(
                            Icons.thumb_up_outlined,
                            size: 20,
                            color: reactionColor,
                          ),
                    const SizedBox(width: 5),
                    Text(
                      likesCount > 0
                          ? "$likesCount $reactionLabel"
                          : reactionLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: reactionColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // زرار الكومنت
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${widget.commentsCount}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              if (widget.isServiceOffer) _buildOrderButton(),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => isSaved = !isSaved),
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved
                      ? Color(AppColors.primaryColor)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Color(AppColors.primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "طلب خدمة",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
