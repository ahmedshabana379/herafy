import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/networks/end_points.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/cubits/posts_comments/posts_and_comments_cubit.dart';
import 'package:herafy/features/home/cubits/posts_comments/posts_and_comments_state.dart';
import 'package:herafy/features/home/models/post_models.dart';
import 'package:herafy/features/screens/widgets/comment_item.dart';
import 'package:herafy/features/screens/widgets/reaction_picker.dart';

class PostDetailsPage extends StatefulWidget {
  final PostModel post;
  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  late int likesCount;
  int? myReaction;
  final TextEditingController _commentController = TextEditingController();
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
    context.read<SocialCubit>().getComments(widget.post.id);
  }

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    String domain = AppEndPoints.baseUrl.replaceAll('/api/', '');
    return domain.endsWith('/') ? "$domain$path" : "$domain/$path";
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

  void _showReactionPicker() {
    final RenderBox? button =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (button == null) return;
    final position = button.localToGlobal(Offset.zero);
    _reactionOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _reactionOverlay?.remove();
          _reactionOverlay = null;
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned(
              top: position.dy - 70,
              left: position.dx,
              child: ReactionPicker(
                selectedReaction: myReaction,
                onReactionSelected: (r) {
                  _onReactionSelected(r);
                  _reactionOverlay?.remove();
                  _reactionOverlay = null;
                },
                onClose: () {
                  _reactionOverlay?.remove();
                  _reactionOverlay = null;
                },
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_reactionOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _getFullImageUrl(widget.post.clientPictureUrl);
    final postImg = widget.post.imageUrls.isNotEmpty
        ? _getFullImageUrl(widget.post.imageUrls.first)
        : "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          "المنشور",
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        backgroundColor: Colors.white,

        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPostContent(avatarUrl, postImg),
                  const Divider(thickness: 6, color: Color(0xFFF5F5F5)),
                  _buildCommentsList(),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostContent(String avatar, String image) {
    final reactionEmoji = myReaction != null
        ? reactionEmojis[myReaction]
        : null;
    final color = reactionColors[myReaction] ?? Colors.grey;
    final label = reactionLabels[myReaction] ?? "إعجاب";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty ? const Icon(Icons.person) : null,
          ),
          title: Text(
            widget.post.clientName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(widget.post.isProvider ? "مزود خدمة" : "عميل"),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.post.description,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        if (image.isNotEmpty)
          Image.network(image, width: double.infinity, fit: BoxFit.fitWidth),
        Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            key: _buttonKey,
            onLongPress: _showReactionPicker,
            onTap: () => _onReactionSelected(myReaction ?? 1),
            child: Row(
              children: [
                reactionEmoji != null
                    ? Text(reactionEmoji, style: const TextStyle(fontSize: 22))
                    : Icon(Icons.thumb_up_outlined, size: 22, color: color),
                const SizedBox(width: 8),
                Text(
                  likesCount > 0 ? "$likesCount $label" : label,
                  style: TextStyle(fontWeight: FontWeight.w600, color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsList() {
    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        final cubit = context.read<SocialCubit>();
        if (state is GetCommentsLoading)
          return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cubit.comments.length,
          itemBuilder: (context, index) => CommentItem(
            commentId: cubit.comments[index].id,
            userName: cubit.comments[index].userName,
            content: cubit.comments[index].Message,
            userImage: cubit.comments[index].userImage,
          ),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        top: 12,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "أضف تعليقاً...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.send, color: Color(AppColors.primaryColor)),
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                context.read<SocialCubit>().addComment(
                  postId: widget.post.id,
                  content: _commentController.text,
                );
                _commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
