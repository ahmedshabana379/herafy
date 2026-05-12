class PostReactionModel {
  final int clientId;
  final String clientName;
  final String? clientPictureUrl;
  final int reactionType;

  PostReactionModel({
    required this.clientId,
    required this.clientName,
    this.clientPictureUrl,
    required this.reactionType,
  });

  factory PostReactionModel.fromJson(Map<String, dynamic> json) {
    return PostReactionModel(
      clientId: json['clientId'],
      clientName: json['clientName'],
      clientPictureUrl: json['clientPictureUrl'],
      reactionType: json['reactionType'],
    );
  }
}