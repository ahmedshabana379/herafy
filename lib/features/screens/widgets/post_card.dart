import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/screens/post_details_page.dart';

class PostCard extends StatefulWidget {
  final int postId;
  final String providerName, providerJob, timeAgo, description, imageUrl;
  final int likesCount, commentsCount;
  final bool isServiceOffer;
  final String avatarUrl;

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
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  bool isSaved = false;
  late int likesCount;

  @override
  void initState() {
    super.initState();
    likesCount = widget.likesCount;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailsPage(
            post: widget,
            postId: widget.postId,
            isInitialLiked: isLiked,
            initialLikesCount: likesCount,
            onBack: (newLiked, newCount) {
              setState(() {
                isLiked = newLiked;
                likesCount = newCount;
              });
            },
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
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
            _buildActions(),
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
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
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

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          _ActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: "$likesCount",
            color: isLiked ? Colors.redAccent : Colors.grey.shade600,
            onTap: () {
              setState(() {
                isLiked = !isLiked;
                likesCount += isLiked ? 1 : -1;
              });
            },
          ),
          const SizedBox(width: 20),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: "${widget.commentsCount}",
            color: Colors.grey.shade600,
            onTap: () {
              // ممكن نضيف كول باك لفتح صفحة التعليقات مباشرة
            },
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
