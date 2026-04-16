// lib/features/home/models/service_request_model_provider.dart
import 'package:herafy/features/home/models/service_request_model.dart';

class ServiceRequestModelProvider {
  final int id;
  final int requestStatus;
  final String description;
  final double? finalPrice;
  final String createdAt;
  final String? preferredTime;
  final String clientName;
  final String? clientPictureUrl;
  final int? providerId;
  final ServiceRequestLocation location;
  final int serviceId;
  final List<String> imageUrls;
  final bool isUrgent;

  ServiceRequestModelProvider({
    required this.id,
    required this.requestStatus,
    required this.description,
    this.finalPrice,
    required this.createdAt,
    this.preferredTime,
    required this.clientName,
    this.clientPictureUrl,
    this.providerId,
    required this.location,
    required this.serviceId,
    required this.imageUrls,
    required this.isUrgent,
  });

  String get status {
    switch (requestStatus) {
      case 0:
        return 'Pending';
      case 1:
        return 'Assigned';
      case 2:
        return 'InProgress';
      case 3:
        return 'Completed';
      case 4:
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  String get statusText {
    switch (requestStatus) {
      case 0:
        return 'قيد الانتظار';
      case 1:
        return 'تم التخصيص';
      case 2:
        return 'قيد التنفيذ';
      case 3:
        return 'مكتمل';
      case 4:
        return 'ملغي';
      default:
        return 'غير معروف';
    }
  }

  double get budget => finalPrice ?? 0;
  double get latitude {
    print("📍 Latitude from API: ${location.latitude}"); // للتأكد
    return location.latitude;
  }

  double get longitude {
    print("📍 Longitude from API: ${location.longitude}"); // للتأكد
    return location.longitude;
  }

  // bool get isUrgent => isUrgent; // مش موجود في الResponse دلوقتي

  factory ServiceRequestModelProvider.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModelProvider(
      id: json['id'] ?? 0,
      requestStatus: json['requestStatus'] ?? 0,
      description: json['description'] ?? '',
      finalPrice: json['finalPrice']?.toDouble(),
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      preferredTime: json['preferredTime'],
      clientName: json['clientName'] ?? 'عميل',
      clientPictureUrl: json['clientPictureUrl'],
      providerId: json['providerId'],
      location: ServiceRequestLocation.fromJson(
        json['serviceRequestLocation'] ?? {},
      ),
      serviceId: json['serviceId'] ?? 0,
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      isUrgent: json['isUrgent'] ?? false,
    );
  }
}
