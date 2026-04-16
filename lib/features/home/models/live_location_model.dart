// lib/features/home/models/live_location_model.dart

class UpdateLiveLocationRequestModel {
  final double latitude;
  final double longitude;

  UpdateLiveLocationRequestModel({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }
}

class LiveLocationResponseModel {
  final int userId;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;
  final bool isOnline;

  LiveLocationResponseModel({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
    required this.isOnline,
  });

  factory LiveLocationResponseModel.fromJson(Map<String, dynamic> json) {
    return LiveLocationResponseModel(
      userId: json['userId'] ?? 0,
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      isOnline: json['isOnline'] ?? false,
    );
  }
}