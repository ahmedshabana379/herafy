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