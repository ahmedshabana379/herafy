import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/networks/end_points.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/cubits/posts_comments/posts_and_comments_cubit.dart';
import 'package:herafy/features/home/models/post_models.dart';
import 'package:herafy/features/screens/post_details_page.dart';
import 'package:herafy/features/screens/widgets/reaction_picker.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isSaved = false;
  int? myReaction;
  late int likesCount;
  bool _showReactions = false;
  OverlayEntry? _reactionOverlay;
  final GlobalKey _buttonKey = GlobalKey();

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
    likesCount = widget.post.totalReactionsCount;
    myReaction = widget.post.userReaction;
  }

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    String domain = AppEndPoints.baseUrl.replaceAll('/api/', '');
    return domain.endsWith('/') ? "$domain$path" : "$domain/$path";
  }

  void _removeReactionOverlay() {
    _reactionOverlay?.remove();
    _reactionOverlay = null;
    setState(() => _showReactions = false);
  }

  void _showReactionPicker() {
    final RenderBox? button =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
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
    setState(() => _showReactions = true);
  }

  void _onReactionSelected(int reaction) {
    setState(() {
      if (myReaction == reaction) {
        myReaction = null;
        likesCount--;
      } else {
        if (myReaction == null) likesCount++;
        myReaction = reaction;
      }
    });
    context.read<SocialCubit>().reactToPost(
      postId: widget.post.id,
      reactionType: reaction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reactionEmoji = myReaction != null
        ? reactionEmojis[myReaction]
        : null;
    final reactionColor = reactionColors[myReaction] ?? Colors.grey.shade600;
    final reactionLabel = reactionLabels[myReaction] ?? "إعجاب";
    final avatarUrl = _getFullImageUrl(widget.post.clientPictureUrl);
    final postImageUrl = widget.post.imageUrls.isNotEmpty
        ? _getFullImageUrl(widget.post.imageUrls.first)
        : "";

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostDetailsPage(post: widget.post)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(avatarUrl),
            _buildDescription(),
            _buildImage(
              postImageUrl.isEmpty
                  ? "https://via.placeholder.com/400x200"
                  : postImageUrl,
            ),
            _buildActions(reactionEmoji, reactionColor, reactionLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String avatarUrl) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(AppColors.cardsColor),
            backgroundImage: avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl.isEmpty
                ? Icon(Icons.person, color: Color(AppColors.primaryColor))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.clientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.post.isProvider ? "مزود خدمة" : "عميل",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(AppColors.secondaryColor),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.more_horiz, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        widget.post.description,
        style: const TextStyle(fontSize: 14, height: 1.4),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImage(String url) {
    return ClipRRect(
      child: Image.network(
        url,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildActions(String? emoji, Color color, String label) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GestureDetector(
            key: _buttonKey,
            onLongPress: _showReactionPicker,
            onTap: () => _onReactionSelected(myReaction ?? 1),
            child: Row(
              children: [
                emoji != null
                    ? Text(emoji, style: const TextStyle(fontSize: 18))
                    : Icon(Icons.thumb_up_outlined, size: 20, color: color),
                const SizedBox(width: 5),
                Text(
                  likesCount > 0 ? "$likesCount $label" : label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Icon(
            Icons.chat_bubble_outline,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 5),
          Text(
            "${widget.post.commentsCount}",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const Spacer(),
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
}
