class ServiceRequestModel {
  final int id;
  final String description;
  final int serviceId;
  final String serviceName;
  final double budget;
  final double latitude;
  final double longitude;
  final String locationAddress;
  final List<String> images;
  final String status; // Pending, Assigned, InProgress, Completed, Cancelled
  final String createdAt;
  final String? clientName;
  final int? clientId;
  final bool isUrgent;
  ServiceRequestModel({
    required this.id,
    required this.description,
    required this.serviceId,
    required this.serviceName,
    required this.budget,
    required this.latitude,
    required this.longitude,
    required this.locationAddress,
    required this.images,
    required this.status,
    required this.createdAt,
    this.clientName,
    this.clientId,
    this.isUrgent = false,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      serviceId: json['serviceId'] ?? 0,
      serviceName: json['serviceName'] ?? '',
      budget: (json['budget'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      locationAddress: json['locationAddress'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      clientName: json['clientName'],
      clientId: json['clientId'],
      isUrgent: json['isUrgent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'budget': budget,
      'latitude': latitude,
      'longitude': longitude,
      'locationAddress': locationAddress,
      'images': images,
      'status': status,
      'createdAt': createdAt,
      'clientName': clientName,
      'clientId': clientId,
      'isUrgent': isUrgent,
    };
  }
}