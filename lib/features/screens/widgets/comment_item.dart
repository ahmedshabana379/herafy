import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/cubits/posts_comments/posts_and_comments_cubit.dart';

class CommentItem extends StatefulWidget {
  final int commentId;
  final String userName;
  final String content;
  final String? userImage;
  final int reactionsCount;

  const CommentItem({
    super.key,
    required this.commentId,
    required this.userName,
    required this.content,
    this.userImage,
    this.reactionsCount = 0,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _showReactions = false;
  int? myReaction;
  late int reactionsCount;

  static const Map<int, String> reactionEmojis = {
    1: "👍", 2: "❤️", 3: "😂", 4: "😡", 5: "😢"
  };
  static const Map<int, Color> reactionColors = {
    1: Colors.blue, 2: Colors.red,
    3: Colors.amber, 4: Colors.orange, 5: Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    reactionsCount = widget.reactionsCount;
  }

  void _onReactionSelected(int reaction) {
    setState(() {
      if (myReaction == reaction) {
        myReaction = null;
        reactionsCount--;
      } else {
        if (myReaction == null) reactionsCount++;
        myReaction = reaction;
      }
      _showReactions = false;
    });
    context.read<SocialCubit>().reactToComment(
      commentId: widget.commentId,
      reactionType: reaction,
    );
  }

  @override
  Widget build(BuildContext context) {
    const baseUrl = "https://iti-final-project.runasp.net/";
    final avatarUrl = widget.userImage != null
        ? "$baseUrl${widget.userImage}"
        : "";

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المستخدم
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(AppColors.cardsColor),
            backgroundImage: avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            onBackgroundImageError: avatarUrl.isNotEmpty
                ? (_, __) {}
                : null,
            child: avatarUrl.isEmpty
                ? Icon(Icons.person, size: 18,
                    color: Color(AppColors.primaryColor))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الكومنت bubble
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(widget.content,
                          style: const TextStyle(fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),

                // Reaction picker
                if (_showReactions)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8)
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: reactionEmojis.entries.map((e) {
                        return GestureDetector(
                          onTap: () => _onReactionSelected(e.key),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(e.value,
                                style: const TextStyle(fontSize: 22)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Action row
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Row(
                    children: [
                      // زرار الـ reaction
                      GestureDetector(
                        onLongPress: () =>
                            setState(() => _showReactions = !_showReactions),
                        onTap: () => myReaction == null
                            ? _onReactionSelected(1)
                            : _onReactionSelected(myReaction!),
                        child: Row(
                          children: [
                            myReaction != null
                                ? Text(reactionEmojis[myReaction]!,
                                    style: const TextStyle(fontSize: 14))
                                : Icon(Icons.thumb_up_outlined,
                                    size: 14,
                                    color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              reactionsCount > 0
                                  ? "$reactionsCount"
                                  : "إعجاب",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: myReaction != null
                                      ? reactionColors[myReaction]
                                      : Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ],
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