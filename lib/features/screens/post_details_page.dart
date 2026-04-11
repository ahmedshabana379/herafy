import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/snack_bar_helper.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/cubits/posts_comments/posts_and_comments_cubit.dart';
import 'package:herafy/features/home/cubits/posts_comments/posts_and_comments_state.dart';
import 'package:herafy/features/screens/widgets/comment_item.dart';
import 'package:herafy/features/screens/widgets/post_card.dart';

class PostDetailsPage extends StatefulWidget {
  final PostCard post;
  final int postId;
  final bool isInitialLiked;
  final int initialLikesCount;
  final Function(bool, int) onBack; // لتحديث الكارت عند الرجوع
  final int? initialReactionType;

  const PostDetailsPage({
    super.key,
    required this.post,
    required this.postId,
    required this.isInitialLiked,
    required this.initialLikesCount,
    required this.onBack, this.initialReactionType,
  });

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  late bool isLiked;
  late int likesCount;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.isInitialLiked;
    likesCount = widget.initialLikesCount;
    myReaction = widget.initialReactionType; 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.postId > 0) {
        context.read<SocialCubit>().getComments(widget.postId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBack(isLiked, likesCount); // نبعت التحديثات للكارت
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "المنشور",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          elevation: 0.5,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
              widget.onBack(isLiked, likesCount);
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFullPostContent(),
                    const Divider(thickness: 6, color: Color(0xFFF5F5F5)),
                    _buildCommentsHeader(),
                    _buildCommentsList(),
                  ],
                ),
              ),
            ),
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildFullPostContent() {
    const baseUrl = "https://iti-final-project.runasp.net/";
    final avatarUrl = widget.post.avatarUrl.isNotEmpty
        ? widget.post.avatarUrl
        : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: Color(AppColors.cardsColor),
            backgroundImage: avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            onBackgroundImageError: avatarUrl.isNotEmpty ? (_, __) {} : null,
            child: avatarUrl.isEmpty
                ? Icon(Icons.person, color: Color(AppColors.primaryColor))
                : null,
          ),
          title: Text(
            widget.post.providerName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("${widget.post.providerJob} • ${widget.post.timeAgo}"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.post.description,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
        if (widget.post.imageUrl.isNotEmpty)
          Hero(
            tag: widget.post.imageUrl,
            child: Image.network(
              widget.post.imageUrl,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

        // Reactions row
        _buildReactionsRow(),
      ],
    );
  }

  // أضف الـ state variables في _PostDetailsPageState
  bool _showReactions = false;
  int? myReaction;

  static const Map<int, String> _reactionEmojis = {
    1: "👍",
    2: "❤️",
    3: "😂",
    4: "😡",
    5: "😢",
  };
  static const Map<int, String> _reactionLabels = {
    1: "إعجاب",
    2: "حب",
    3: "ضحك",
    4: "غضب",
    5: "حزن",
  };
  static const Map<int, Color> _reactionColors = {
    1: Colors.blue,
    2: Colors.red,
    3: Colors.amber,
    4: Colors.orange,
    5: Colors.blue,
  };

  Widget _buildReactionsRow() {
    final reactionEmoji = myReaction != null
        ? _reactionEmojis[myReaction]
        : null;
    final reactionColor = myReaction != null
        ? _reactionColors[myReaction]!
        : Colors.grey;
    final reactionLabel = myReaction != null
        ? _reactionLabels[myReaction]!
        : "إعجاب";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showReactions)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _reactionEmojis.entries.map((e) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (myReaction == e.key) {
                          myReaction = null;
                          likesCount--;
                        } else {
                          if (myReaction == null) likesCount++;
                          myReaction = e.key;
                        }
                        _showReactions = false;
                      });
                      context.read<SocialCubit>().reactToPost(
                        postId: widget.postId,
                        reactionType: e.key,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onLongPress: () =>
                    setState(() => _showReactions = !_showReactions),
                onTap: () {
                  setState(() {
                    if (myReaction != null) {
                      myReaction = null;
                      likesCount--;
                    } else {
                      myReaction = 1;
                      likesCount++;
                    }
                  });
                  context.read<SocialCubit>().reactToPost(
                    postId: widget.postId,
                    reactionType: myReaction ?? 1,
                  );
                },
                child: Row(
                  children: [
                    reactionEmoji != null
                        ? Text(
                            reactionEmoji,
                            style: const TextStyle(fontSize: 22),
                          )
                        : Icon(
                            Icons.thumb_up_outlined,
                            size: 22,
                            color: reactionColor,
                          ),
                    const SizedBox(width: 8),
                    Text(
                      likesCount > 0
                          ? "$likesCount $reactionLabel"
                          : reactionLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: reactionColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsHeader() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            "التعليقات",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        final cubit = context.read<SocialCubit>();
        if (state is GetCommentsLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (cubit.comments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "لا توجد تعليقات بعد",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cubit.comments.length,
          itemBuilder: (context, index) {
            final comment = cubit.comments[index];
            return CommentItem(
              commentId: comment.id,
              userImage: comment.userImage,
              userName: comment.userName,
              content: comment.Message,
              reactionsCount: comment.reactionsCount,
            );
          },
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "أضف تعليقاً بصفتك عميلاً...",
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          BlocConsumer<SocialCubit, SocialState>(
            listener: (context, state) {
              if (state is AddCommentSuccess) {
                _commentController.clear();
              } else if (state is AddCommentError) {
                SnackBarHelper.showErrorSnackBar(context, state.error);
              }
            },
            builder: (context, state) {
              final isSending = state is AddCommentLoading;
              return GestureDetector(
                onTap: isSending || widget.postId <= 0
                    ? null
                    : () {
                        context.read<SocialCubit>().addComment(
                          postId: widget.postId,
                          content: _commentController.text,
                        );
                      },
                child: CircleAvatar(
                  backgroundColor: Color(AppColors.primaryColor),
                  child: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
