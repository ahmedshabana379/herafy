class UserModel {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? pictureUrl;
  final String? accessToken;
  final List<String> roles;
  final bool? isAuthenticated;
  final bool? isProfileComplete;
  final int
  status; // 0=Pending, 1=UnderReview, 2=Approved, 3=Rejected, 4=Suspended, 5=Completed
  final bool? isProviderFromServer;
  final int? gender;
  final String? phoneNumber;
  final int? governorateId;
  final int? regionId;
  final String? birthDate;
  // الـ ID عشان نبعته في الـ Update
  final String? governorateName; // للعرض في البروفايل
  final String? regionName;
  UserModel({
    this.firstName,
    this.lastName,
    this.email,
    this.pictureUrl,
    this.accessToken,
    this.roles = const [],
    this.isAuthenticated,
    this.isProfileComplete = false,
    this.status = 0,
    this.isProviderFromServer,
    this.gender,
    this.phoneNumber,
    this.governorateId,
    this.regionId,
    this.birthDate,
    this.governorateName,
    this.regionName,
  });

  bool get isProvider =>
      isProviderFromServer == true ||
      roles.any(
        (r) =>
            r.toLowerCase() == 'provider' ||
            r.toLowerCase() == 'serviceprovider',
      );
  bool get isClient => roles.any((r) => r.toLowerCase() == 'client');
  bool get isAdmin => roles.any((r) => r.toLowerCase() == 'admin');

  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedRoles = [];
    final dynamic rolesRaw = json['roles'] ?? json['role'];
    if (rolesRaw is List) {
      parsedRoles = rolesRaw.map((e) => e.toString()).toList();
    } else if (rolesRaw is String && rolesRaw.trim().isNotEmpty) {
      parsedRoles = [rolesRaw.trim()];
    }

    final int status = json['status'] ?? 0;

    return UserModel(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      pictureUrl: json['pictureUrl'],
      accessToken: json['accessToken'],
      roles: parsedRoles,
      isAuthenticated: json['isAuthenticated'],
      isProfileComplete: json['isProfileComplete'] ?? (status == 5),
      status: status,
      isProviderFromServer: json['isProvider'],
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      governorateId: json['governorateId'],
      regionId: json['regionId'],
      birthDate: json['birthDate'],
      governorateName: json['governorateName'],
      regionName: json['regionName'],
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
      'status': status,
      'isProvider': isProviderFromServer,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'governorateId': governorateId,
      'regionId': regionId,
      'birthDate': birthDate,
      'governorateName': governorateName,
      'regionName': regionName,
    };
  }

  UserModel copyWith({
    bool? isProviderFromServer,
    String? firstName,
    String? lastName,
    String? email,
    String? pictureUrl,
    String? accessToken,
    List<String>? roles,
    bool? isAuthenticated,
    bool? isProfileComplete,
    int? status,
    int? gender,
    String? phoneNumber,
    int? governorateId,
    int? regionId,
    String? birthDate,
    String? governorateName,
    String? regionName,
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
      status: status ?? this.status,
      isProviderFromServer: isProviderFromServer ?? this.isProviderFromServer,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      governorateId: governorateId ?? this.governorateId,
      regionId: regionId ?? this.regionId,
      birthDate: birthDate ?? this.birthDate,
      governorateName: governorateName ?? this.governorateName,
      regionName: regionName ?? this.regionName,
    );
  }
}
