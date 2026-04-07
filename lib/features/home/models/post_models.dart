class PostModel {
  final int id;
  final String title;
  final String? description;
  final List<String>? images;
  final int? governorateId;
  final int? regionId;
  final int reactionsCount;
  final bool isReacted; 

  PostModel({
    required this.id,
    required this.title,
    this.description,
    this.images,
    this.governorateId,
    this.regionId,
    this.reactionsCount = 0,
    this.isReacted = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      governorateId: json['governorateId'],
      regionId: json['regionId'],
      reactionsCount: json['reactionsCount'] ?? 0,
      isReacted: json['isReacted'] ?? false,
    );
  }
}