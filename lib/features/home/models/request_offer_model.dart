class RequestOfferModel {
  final int id;
  final int serviceRequestId;
  final int providerId;
  final String? providerName;
  final String? providerPictureUrl;
  final double price;
  final String message;
  final String status; // Pending, Accepted, Rejected
  final String createdAt;

  RequestOfferModel({
    required this.id,
    required this.serviceRequestId,
    required this.providerId,
    this.providerName,
    this.providerPictureUrl,
    required this.price,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory RequestOfferModel.fromJson(Map<String, dynamic> json) {
    return RequestOfferModel(
      id: json['id'] ?? 0,
      serviceRequestId: json['serviceRequestId'] ?? 0,
      providerId: json['providerId'] ?? 0,
      providerName: json['providerName'],
      providerPictureUrl: json['providerPictureUrl'],
      price: (json['price'] ?? 0).toDouble(),
      message: json['message'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceRequestId': serviceRequestId,
      'providerId': providerId,
      'providerName': providerName,
      'providerPictureUrl': providerPictureUrl,
      'price': price,
      'message': message,
      'status': status,
      'createdAt': createdAt,
    };
  }
}