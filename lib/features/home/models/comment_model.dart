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

// class CommentModel {
//   final int id;
//   final String message;
//   final int postId;
//   final int clientId;
//   final String clientName;
//   final String? clientPictureUrl;
//   final String createdAt;
//   final bool isProvider;
//   final int? providerId;
//   final int? userReaction; // رياكت المستخدم الحالي (1-5 أو null)
//   final List<Map<String, dynamic>> reactions; // قائمة الرياكتس مع العدد

//   CommentModel({
//     required this.id,
//     required this.message,
//     required this.postId,
//     required this.clientId,
//     required this.clientName,
//     this.clientPictureUrl,
//     required this.createdAt,
//     required this.isProvider,
//     this.providerId,
//     this.userReaction,
//     this.reactions = const [],
//   });

//   // حساب إجمالي الرياكتس
//   int get totalReactionsCount {
//     return reactions.fold(0, (sum, item) => sum + (item['count'] as int? ?? 0));
//   }

//   // جلب الرياكتس الأكثر استخداماً
//   List<Map<String, dynamic>> get topReactions {
//     return reactions.take(3).toList();
//   }

//   factory CommentModel.fromJson(Map<String, dynamic> json) {
//     return CommentModel(
//       id: json['id'] ?? 0,
//       message: json['message'] ?? '',
//       postId: json['postId'] ?? 0,
//       clientId: json['clientId'] ?? 0,
//       clientName: json['clientName'] ?? 'مستخدم',
//       clientPictureUrl: json['clientPictureUrl'],
//       createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
//       isProvider: json['isProvider'] ?? false,
//       providerId: json['providerId'],
//       userReaction: json['userReaction'],
//       reactions: json['reactions'] != null && json['reactions'] is List
//           ? List<Map<String, dynamic>>.from(json['reactions'])
//           : [],
//     );
//   }
// }