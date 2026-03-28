import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.providerName,
    required this.providerJob,
    required this.timeAgo,
    required this.description,
    required this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isServiceOffer = false,
  });

  final String providerName;
  final String providerJob;
  final String timeAgo;
  final String description;
  final String imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool isServiceOffer;

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الهيدر - اسم الحرفي
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(AppColors.cardsColor),
                  child: Icon(
                    Icons.person,
                    color: Color(AppColors.primaryColor),
                  ),
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
                              fontSize: 12,
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
          ),

          // الصورة
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Image.network(
              widget.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Color(AppColors.cardsColor),
                child: Icon(
                  Icons.image_outlined,
                  size: 50,
                  color: Color(AppColors.primaryColor),
                ),
              ),
            ),
          ),

          // الوصف
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.description,
              style: TextStyle(
                fontSize: 14,
                color: Color(AppColors.secondaryColor),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // الأكشنز
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                // لايك
                _ActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: "$likesCount",
                  color: isLiked ? Colors.redAccent : Colors.grey.shade500,
                  onTap: () {
                    setState(() {
                      isLiked = !isLiked;
                      likesCount += isLiked ? 1 : -1;
                    });
                  },
                ),
                const SizedBox(width: 16),

                // كومنت
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: "${widget.commentsCount}",
                  color: Colors.grey.shade500,
                  onTap: () {},
                ),

                const Spacer(),
                // زرار طلب الخدمة - بيظهر بس لو service offer
                if (widget.isServiceOffer) ...[
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      "طلب الخدمة",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // سيف
                GestureDetector(
                  onTap: () {
                    setState(() => isSaved = !isSaved);
                  },
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved
                        ? Color(AppColors.primaryColor)
                        : Colors.grey.shade500,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }
}
