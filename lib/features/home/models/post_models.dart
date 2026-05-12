class PostModel {
  final int id;
  final int clientId;
  final int governorateId;
  final int regionId;
  final String title;
  final String description;
  final DateTime createdAt;
  final List<String> imageUrls;
  final int commentsCount;
  final List<TopReaction> topReactions;
  final bool isProvider;
  final int? providerId;
  final String clientName;
  final String? clientPictureUrl;
  final int? userReaction;

  PostModel({
    required this.id,
    required this.clientId,
    required this.governorateId,
    required this.regionId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.imageUrls,
    required this.commentsCount,
    required this.topReactions,
    required this.isProvider,
    this.providerId,
    required this.clientName,
    this.clientPictureUrl,
    this.userReaction,
  });

  // --- الهيدر الخاص بحساب إجمالي التفاعلات ---
  int get totalReactionsCount {
    return topReactions.fold(0, (sum, element) => sum + element.count);
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      clientId: json['clientId'] ?? 0,
      governorateId: json['governorateId'] ?? 0,
      regionId: json['regionId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      commentsCount: json['commentsCount'] ?? 0,
      topReactions: (json['topReactions'] as List?)
              ?.map((e) => TopReaction.fromJson(e))
              .toList() ?? [],
      isProvider: json['isProvider'] ?? false,
      providerId: json['providerId'],
      clientName: json['clientName'] ?? 'Unknown',
      clientPictureUrl: json['clientPictureUrl'],
      userReaction: json['userReaction'],
    );
  }
}

class TopReaction {
  final int reactionType;
  final int count;

  TopReaction({
    required this.reactionType,
    required this.count,
  });

  factory TopReaction.fromJson(Map<String, dynamic> json) {
    return TopReaction(
      reactionType: json['reactionType'] ?? 0,
      count: json['count'] ?? 0,
    );
  }
}