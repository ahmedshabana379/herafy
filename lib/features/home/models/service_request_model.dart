class ServiceRequestModel {
  final int id;
  final int requestStatus; // 0 = Pending, 1 = Assigned, etc.
  final String description;
  final double? finalPrice;
  final String createdAt;
  final String? preferredTime;
  final int clientId;
  final int? providerId;
  final ServiceRequestLocation location;
  final int serviceId;
  final List<String> imageUrls;

  ServiceRequestModel({
    required this.id,
    required this.requestStatus,
    required this.description,
    this.finalPrice,
    required this.createdAt,
    this.preferredTime,
    required this.clientId,
    this.providerId,
    required this.location,
    required this.serviceId,
    required this.imageUrls,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'] ?? 0,
      requestStatus: json['requestStatus'] ?? 0,
      description: json['description'] ?? '',
      finalPrice: json['finalPrice']?.toDouble(),
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      preferredTime: json['preferredTime'],
      clientId: json['clientId'] ?? 0,
      providerId: json['providerId'],
      serviceId: json['serviceId'] ?? 0,
      location: ServiceRequestLocation.fromJson(json['serviceRequestLocation'] ?? {}),
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestStatus': requestStatus,
      'description': description,
      'finalPrice': finalPrice,
      'createdAt': createdAt,
      'preferredTime': preferredTime,
      'clientId': clientId,
      'providerId': providerId,
      'serviceRequestLocation': location.toJson(),
      'serviceId': serviceId,
      'imageUrls': imageUrls,
    };
  }
  
  // Getter للحالة كنص
  String get statusText {
    switch (requestStatus) {
      case 0: return 'قيد الانتظار';
      case 1: return 'تم التعيين';
      case 2: return 'قيد التنفيذ';
      case 3: return 'مكتمل';
      case 4: return 'ملغي';
      default: return 'غير معروف';
    }
  }

  String get serviceName => 'اسم الخدمة'; // Placeholder, يجب استبداله بالاسم الحقيقي للخدمة بناءً على serviceId
}

class ServiceRequestLocation {
  final double latitude;
  final double longitude;

  ServiceRequestLocation({
    required this.latitude,
    required this.longitude,
  });

  factory ServiceRequestLocation.fromJson(Map<String, dynamic> json) {
    return ServiceRequestLocation(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}