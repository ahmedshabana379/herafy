import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  int? selectedRole;
  // role selection logic
  void selectRole(int role) {
    if (selectedRole == role) {
      selectedRole = null; // Deselect if the same role is tapped again
    } else {
      selectedRole = role;
    }
    emit(SelectRoleState(selectedRole!));
  }

  //  buttons logic
  void onContinue() {
    if (selectedRole != null) {
      // logic to navigate to the next screen based on the selected role
    } else {
      // display a message to select a role first and make button disabled
    }
  }

  // login logic
  Future<void> login( {required String email, required String password}) async {
    emit(LoginLoading());
    try {
      await Future.delayed(Duration(seconds: 5));
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
