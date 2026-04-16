// lib/features/home/models/review_model.dart

class CreateReviewRequestModel {
  final int serviceRequestId;
  final double rating;
  final String message;

  CreateReviewRequestModel({
    required this.serviceRequestId,
    required this.rating,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'ServiceRequestId': serviceRequestId,
      'Rating': rating,
      'Message': message,
    };
  }
}

class ReviewResponseModel {
  final int id;
  final int serviceRequestId;
  final int reviewerId;
  final int revieweeId;
  final double rating;
  final String message;
  final DateTime createdAt;

  ReviewResponseModel({
    required this.id,
    required this.serviceRequestId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.message,
    required this.createdAt,
  });

  factory ReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewResponseModel(
      id: json['id'] ?? 0,
      serviceRequestId: json['serviceRequestId'] ?? 0,
      reviewerId: json['reviewerId'] ?? 0,
      revieweeId: json['revieweeId'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}