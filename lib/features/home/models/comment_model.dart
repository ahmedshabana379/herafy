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
    String name = json['clientName'] ??
        json['userName'] ??
        json['authorName'] ??
        json['fullName'] ??
        json['name'] ??
        'مستخدم';

    if (name.trim().isEmpty || name.trim().toLowerCase() == 'user') {
      name = 'مستخدم';
    }

    return CommentModel(
      id: json['id'] ?? 0,
      Message: json['message'] ?? json['Message'] ?? '',
      postId: json['postId'] ?? 0,
      userName: name,
      userImage: json['clientPictureUrl'] ?? json['userImage'],
      reactionsCount: json['reactionsCount'] ?? 0,
    );
  }
}