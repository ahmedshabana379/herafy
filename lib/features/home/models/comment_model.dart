class CommentModel {
  final int id;
  final String Message;
  final int postId;
  final String userName;
  final String? userImage;
  final int reactionsCount;

  CommentModel({
    required this.id,
    required this.Message,
    required this.postId,
    required this.userName,
    this.userImage,
    this.reactionsCount = 0,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      Message: json['message'] ?? '',
      postId: json['postId'],
      userName: json['userName'] ?? 'User',
      userImage: json['userImage'],
      reactionsCount: json['reactionsCount'] ?? 0,
    );
  }
}