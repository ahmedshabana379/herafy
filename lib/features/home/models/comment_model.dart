class CommentModel {
  final int id;
  final String content;
  final int postId;
  final String userName;
  final String? userImage;
  final int reactionsCount;

  CommentModel({
    required this.id,
    required this.content,
    required this.postId,
    required this.userName,
    this.userImage,
    this.reactionsCount = 0,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      content: json['content'] ?? '',
      postId: json['postId'],
      userName: json['userName'] ?? 'User',
      userImage: json['userImage'],
      reactionsCount: json['reactionsCount'] ?? 0,
    );
  }
}