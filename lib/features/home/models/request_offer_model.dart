class RequestOfferModel {
  final int id;
  final int? serviceRequestId; // بيجي في الـ Create بس
  final int? providerId;      // بيجي في الـ Get بس
  final String? providerName;
  final String? providerPictureUrl;
  final double price;
  final String message;
  final DateTime createdAt;
  final String? status; // ضفته عشان لو محتاجه في الـ UI لاحقاً

  RequestOfferModel({
    required this.id,
    this.serviceRequestId,
    this.providerId,
    this.providerName,
    this.providerPictureUrl,
    required this.price,
    required this.message,
    required this.createdAt,
    this.status,
  });

  factory RequestOfferModel.fromJson(Map<String, dynamic> json) {
    return RequestOfferModel(
      id: json['id'],
      // بنستخدم ?? عشان لو الـ Key مش موجود الـ App ميكراشش
      serviceRequestId: json['serviceRequestId'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      providerPictureUrl: json['providerPictureUrl'],
      // السيرفر بيبعت الـ price أحياناً int وأحياناً double، الـ .toDouble() بتحل المشكلة دي
      price: (json['price'] as num).toDouble(),
      message: json['message'] ?? "",
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'], 
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
      'createdAt': createdAt.toIso8601String(),
    };
  }
}