// class PostModel {
//   final int id;
//   final String title;
//   final String? description;
//   final List<String> imageUrls;
//   final String? clientName;
//   final String? clientPictureUrl;
//   final String? createdAt;
//   final int commentsCount;
//   final bool isProvider;

//   PostModel({
//     required this.id,
//     required this.title,
//     this.description,
//     this.imageUrls = const [],
//     this.clientName,
//     this.clientPictureUrl,
//     this.createdAt,
//     this.commentsCount = 0,
//     this.isProvider = false,
//   });

//   factory PostModel.fromJson(Map<String, dynamic> json) {
//     return PostModel(
//       id: json['id'],
//       title: json['title'] ?? '',
//       description: json['description'],
//       imageUrls: json['imageUrls'] != null
//           ? List<String>.from(json['imageUrls'])
//           : [],
//       clientName: json['clientName'],
//       clientPictureUrl: json['clientPictureUrl'],
//       createdAt: json['createdAt'],
//       commentsCount: json['commentsCount'] ?? 0,
//       isProvider: json['isProvider'] ?? false,
//     );
//   }
// }


class PostModel {
  final int id;
  final String title;
  final String? description;
  final List<String> imageUrls;
  final String? clientName;
  final String? clientPictureUrl;
  final String? createdAt;
  final int commentsCount;
  final bool isProvider;

  PostModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrls = const [],
    this.clientName,
    this.clientPictureUrl,
    this.createdAt,
    this.commentsCount = 0,
    this.isProvider = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      clientName: json['clientName'],
      clientPictureUrl: json['clientPictureUrl'],
      createdAt: json['createdAt'],
      commentsCount: json['commentsCount'] ?? 0,
      isProvider: json['isProvider'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'clientName': clientName,
      'clientPictureUrl': clientPictureUrl,
      'createdAt': createdAt,
      'commentsCount': commentsCount,
      'isProvider': isProvider,
    };
  }
}