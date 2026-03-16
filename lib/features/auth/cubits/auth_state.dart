abstract class AuthState {}

// selectRole
class AuthInitial extends AuthState {}
class SelectRoleState extends AuthState {
  final int selectedRole; 

  SelectRoleState(this.selectedRole);
}


//login 