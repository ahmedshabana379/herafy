import 'package:herafy/features/home/models/location_model.dart';

class CreateRequestResponseModel {
  final int id;
  final int clientId;
  final String description;
  final int requestStatus;
  final DateTime createdAt;
  final LocationModel location;
  final int serviceId;

  CreateRequestResponseModel({
    required this.id,
    required this.clientId,
    required this.description,
    required this.requestStatus,
    required this.createdAt,
    required this.location,
    required this.serviceId,
  });

  factory CreateRequestResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateRequestResponseModel(
      id: json['id'],
      clientId: json['clientId'],
      description: json['description'] ?? "",
      requestStatus: json['requestStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      location: LocationModel.fromJson(json['serviceRequestLocation']),
      serviceId: json['serviceId'],
    );
  }
}
