import 'package:herafy/core/resourses/constants.dart';
import 'package:herafy/features/auth/models/user_model.dart';

abstract class AuthState {}

// selectRole
class AuthInitial extends AuthState {}

class SelectRoleState extends AuthState {
  final UserRole selectedRole;

  SelectRoleState(this.selectedRole);
}

//login

class LoginLoading extends AuthState {}

class LoginSuccess extends AuthState {}

class LoginError extends AuthState {
  final String message;
  LoginError(this.message);
}

// Registration for client

class RegisterLoading extends AuthState {}

class RegisterSuccess extends AuthState {
  final bool isProvider;
  RegisterSuccess(this.isProvider);
}

class RegisterAndNavigateToProviderStep2 extends AuthState {
  final String firstName;
  final String lastName;
  final String email;
  RegisterAndNavigateToProviderStep2({
    required this.firstName,
    required this.lastName,
    required this.email,
  });
}

class RegisterError extends AuthState {
  final String message;
  RegisterError(this.message);
}

// Registration for provider
class ProviderRegisterLoading extends AuthState {}

class ProviderRegisterSuccess extends AuthState {}

class ProviderRegisterError extends AuthState {
  final String message;
  ProviderRegisterError(this.message);
}

// Navigation

class NavigateToCustomerRegister extends AuthState {}

class NavigateToProviderRegister extends AuthState {}

// حالة تحديث الـ UI بعد اختيار المحافظة (الفلترة)
class GovernorateSelectedState extends AuthState {}

// --- Regions & Governorates States (اللي بنجيب بيها المناطق) ---
class GetRegionsLoading extends AuthState {}

class GetRegionsSuccess extends AuthState {}

class GetRegionsError extends AuthState {
  final String message;
  GetRegionsError(this.message);
}

// حالات جلب الحرف (Services)
class GetServicesLoading extends AuthState {}

class GetServicesSuccess extends AuthState {}

class GetServicesError extends AuthState {
  final String message;
  GetServicesError(this.message);
}

// حالات إكمال بيانات البروفايدر من Home
class ProviderProfileCompletionRequired extends AuthState {}

class ProviderProfileCompleted extends AuthState {}

// Change Password
class ChangePasswordLoading extends AuthState {}

class ChangePasswordSuccess extends AuthState {}

class ChangePasswordError extends AuthState {
  final String message;
  ChangePasswordError(this.message);
}

// Logout
class LogoutLoading extends AuthState {}

class LogoutSuccess extends AuthState {}

class LogoutError extends AuthState {
  final String message;
  LogoutError(this.message);

}


class ProviderApprovedState extends AuthState {}
class ProviderRejectedState extends AuthState {}
class ProviderUnderReviewState extends AuthState {}

// Update Profile States
class UpdateProfileLoading extends AuthState {}
class UpdateProfileSuccess extends AuthState {}
class UpdateProfileError extends AuthState {
  final String message;
  UpdateProfileError(this.message);
}