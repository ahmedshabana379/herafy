import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/screens/widgets/comment_item.dart';
import 'package:herafy/features/screens/widgets/post_card.dart';

class PostDetailsPage extends StatefulWidget {
  final PostCard post;
  final bool isInitialLiked;
  final int initialLikesCount;
  final Function(bool, int) onBack; // لتحديث الكارت عند الرجوع

  const PostDetailsPage({
    super.key,
    required this.post,
    required this.isInitialLiked,
    required this.initialLikesCount,
    required this.onBack,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // هيدر البوست
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(AppColors.cardsColor),
            child: Icon(Icons.person, color: Color(AppColors.primaryColor)),
          ),
          title: Text(
            widget.post.providerName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("${widget.post.providerJob} • ${widget.post.timeAgo}"),
        ),
        // وصف كامل
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.post.description,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
        // صورة البوست مع Hero
        Hero(
          tag: widget.post.imageUrl,
          child: Image.network(
            widget.post.imageUrl,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        // تفاعل اللايكات
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  isLiked = !isLiked;
                  likesCount += isLiked ? 1 : -1;
                }),
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "$likesCount لايك",
                style: const TextStyle(fontWeight: FontWeight.w600),
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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) => const CommentItem(),
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
          CircleAvatar(
            backgroundColor: Color(AppColors.primaryColor),
            child: const Icon(Icons.send, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

// ويدجيت التعليق (الريوزبل)
