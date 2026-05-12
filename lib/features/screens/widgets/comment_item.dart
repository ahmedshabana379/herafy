// lib/features/screens/widgets/comment_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/cubits/posts_comments/posts_and_comments_cubit.dart';
import 'package:herafy/features/screens/widgets/reaction_picker.dart';

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
  int? myReaction;
  late int reactionsCount;
  OverlayEntry? _reactionOverlay;
  final GlobalKey _buttonKey = GlobalKey();

  static const Map<int, String> reactionEmojis = {
    1: "👍", 2: "❤️", 3: "😂", 4: "😡", 5: "😢"
  };
  static const Map<int, Color> reactionColors = {
    1: Colors.blue, 2: Colors.red, 3: Colors.amber, 4: Colors.orange, 5: Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    reactionsCount = widget.reactionsCount;
  }

  void _removeReactionOverlay() {
    _reactionOverlay?.remove();
    _reactionOverlay = null;
  }

  void _showReactionPicker() {
    final RenderBox? button = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (button == null) return;
    
    final position = button.localToGlobal(Offset.zero);
    
    _reactionOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeReactionOverlay,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              top: position.dy - 70,
              left: position.dx,
              child: ReactionPicker(
                selectedReaction: myReaction,
                onReactionSelected: (reaction) {
                  _onReactionSelected(reaction);
                  _removeReactionOverlay();
                },
                onClose: _removeReactionOverlay,
              ),
            ),
          ],
        ),
      ),
    );
    
    Overlay.of(context).insert(_reactionOverlay!);
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
    });
    context.read<SocialCubit>().reactToComment(
      commentId: widget.commentId,
      reactionType: reaction,
    );
  }

  @override
  Widget build(BuildContext context) {
    const String baseUrl = "https://iti-final-project.runasp.net/";
    final String fullAvatarUrl = widget.userImage != null ? "$baseUrl${widget.userImage}" : "";

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(AppColors.cardsColor),
            backgroundImage: fullAvatarUrl.isNotEmpty ? NetworkImage(fullAvatarUrl) : null,
            child: fullAvatarUrl.isEmpty
                ? Icon(Icons.person, size: 18, color: Color(AppColors.primaryColor))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.content,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: GestureDetector(
                    key: _buttonKey,
                    onLongPress: _showReactionPicker,
                    onTap: () {
                      if (myReaction == null) {
                        _onReactionSelected(1);
                      } else {
                        _onReactionSelected(myReaction!);
                      }
                    },
                    child: Row(
                      children: [
                        myReaction != null
                            ? Text(reactionEmojis[myReaction]!, style: const TextStyle(fontSize: 14))
                            : Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          reactionsCount > 0 ? "$reactionsCount" : "إعجاب",
                          style: TextStyle(
                            fontSize: 12,
                            color: myReaction != null ? reactionColors[myReaction] : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
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