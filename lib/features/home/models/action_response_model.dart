class ActionResponse {
  final String message;
  final bool status;

  ActionResponse({required this.message, required this.status});

  factory ActionResponse.fromJson(Map<String, dynamic> json) {
    return ActionResponse(
      message: json['message'] ?? 'Operation successful',
      status: json['status'] ?? true,
    );
  }
}