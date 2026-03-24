import 'package:herafy/core/resourses/constants.dart';

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
class RegisterSuccess extends AuthState {}
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

class NavigateToCustomerRegister extends AuthState{}
class NavigateToProviderRegister extends AuthState{}