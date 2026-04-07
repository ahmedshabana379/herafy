class UserModel {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? pictureUrl;
  final String? accessToken;
  final List<String> roles;
  final bool? isAuthenticated;
  final bool? isProfileComplete; // للتحقق من إكمال بيانات البروفايدر

  UserModel({
    this.firstName,
    this.lastName,
    this.email,
    this.pictureUrl,
    this.accessToken,
    this.roles = const [],
    this.isAuthenticated,
    this.isProfileComplete = false,
  });

  // Getters to calculate from roles (case-insensitive)
  bool get isProvider => roles.any(
    (r) =>
        r.toLowerCase() == 'provider' || r.toLowerCase() == 'serviceprovider',
  );
  bool get isClient => roles.any((r) => r.toLowerCase() == 'client');
  bool get isAdmin => roles.any((r) => r.toLowerCase() == 'admin');

  // Full name getter
  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedRoles = [];
    final dynamic rolesRaw = json['roles'] ?? json['role'];
    if (rolesRaw is List) {
      parsedRoles = rolesRaw.map((e) => e.toString()).toList();
    } else if (rolesRaw is String && rolesRaw.trim().isNotEmpty) {
      parsedRoles = [rolesRaw.trim()];
    }

    return UserModel(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      pictureUrl: json['pictureUrl'],
      accessToken: json['accessToken'],
      roles: parsedRoles,
      isAuthenticated: json['isAuthenticated'],
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'pictureUrl': pictureUrl,
      'accessToken': accessToken,
      'roles': roles,
      'isAuthenticated': isAuthenticated,
      'isProfileComplete': isProfileComplete,
    };
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? pictureUrl,
    String? accessToken,
    List<String>? roles,
    bool? isAuthenticated,
    bool? isProfileComplete,
  }) {
    return UserModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      accessToken: accessToken ?? this.accessToken,
      roles: roles ?? this.roles,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
