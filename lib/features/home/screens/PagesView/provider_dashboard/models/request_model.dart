import 'package:herafy/features/home/models/location_model.dart';

class ServiceRequestProviderModel {
  final int id;
  final int requestStatus;
  final String description;
  final double? finalPrice;
  final DateTime createdAt;
  final String? clientName;
  final String? clientPictureUrl;
  final LocationModel location;
  final int serviceId;
  final List<String> imageUrls;

  ServiceRequestProviderModel({
    required this.id,
    required this.requestStatus,
    required this.description,
    this.finalPrice,
    required this.createdAt,
    this.clientName,
    this.clientPictureUrl,
    required this.location,
    required this.serviceId,
    required this.imageUrls,
  });

  factory ServiceRequestProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestProviderModel(
      id: json['id'],
      requestStatus: json['requestStatus'],
      description: json['description'] ?? "",
      finalPrice: json['finalPrice'] != null ? (json['finalPrice'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['createdAt']),
      clientName: json['clientName'],
      clientPictureUrl: json['clientPictureUrl'],
      location: LocationModel.fromJson(json['serviceRequestLocation']),
      serviceId: json['serviceId'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
    );
  }
}
