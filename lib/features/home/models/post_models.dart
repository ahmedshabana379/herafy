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
  final List<dynamic> topReactions;
  final bool isReacted;
  final int? myReactionType;

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
    this.topReactions = const [],
    required this.isReacted,
    this.myReactionType,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    print(
      "POST REACTION DATA: isReacted=${json['isReacted']}, myReaction=${json['myReactionType']}",
    );

    return PostModel(
      isReacted: json['isReacted'] ?? false,
      myReactionType: json['myReactionType'],
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
      topReactions: json['topReactions'] ?? [],
    );
  }
}
