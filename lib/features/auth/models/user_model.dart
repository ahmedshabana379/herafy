class UserModel {
  String? fullName;
  String? email;
  String? pictureUrl;
  String? accessToken;
  List<String>? role;
  bool? isAuthenticated;

  UserModel({
    this.fullName,
    this.email,
    this.pictureUrl,
    this.accessToken,
    this.role,
    this.isAuthenticated,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'],
      email: json['email'],
      pictureUrl: json['pictureUrl'],
      accessToken: json['accessToken'],
      role: json['role'] != null ? List<String>.from(json['role']) : null,
      isAuthenticated: json['isAuthenticated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'pictureUrl': pictureUrl,
      'accessToken': accessToken,
      'role': role,
      'isAuthenticated': isAuthenticated,
    };
  }
}