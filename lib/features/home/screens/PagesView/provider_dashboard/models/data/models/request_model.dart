class ServiceRequest {
  final String clientName;
  final String service;
  final String description;
  final String location;
  final String timeAgo;
  final int budget;
  final bool isUrgent;

  ServiceRequest({
    required this.clientName,
    required this.service,
    required this.description,
    required this.location,
    required this.budget,
    required this.timeAgo,
    this.isUrgent = false,
  });

  factory ServiceRequest.fromMap(Map<String, dynamic> map) {
    return ServiceRequest(
      clientName: map["clientName"] ?? "عميل غير معروف",
      service: map["service"] ?? "خدمة عامة",
      description: map["description"] ?? "لا يوجد وصف",
      location: map["location"] ?? "غير محدد",
      budget: map["budget"] ?? 0,
      timeAgo: map["timeAgo"] ?? "",
      isUrgent: map["isUrgent"] ?? false,
    );
  }
}