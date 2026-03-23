import 'package:herafy/core/resourses/constants.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  // provider data
  String? providerName;
String? providerEmail;
String? providerPassword;
String? providerCategory;
String? providerLocation; 
String? idCardImagePath;
// state for role selection
  UserRole? selectedRole;
  // role selection logic
  void selectRole(UserRole role) {
    if (selectedRole == role) {
      selectedRole = null; // Deselect if the same role is tapped again
    } else {
      selectedRole = role;
    }
    emit(SelectRoleState( selectedRole!));
  }

  //  buttons logic
  void onContinue() {
    if (selectedRole == UserRole.client) {
      // logic to navigate to the next screen based on the selected role
      emit(NavigateToCustomerRegister());

    } else if (selectedRole == UserRole.serviceProvider) {
      // logic to navigate to the next screen based on the selected role
      emit(NavigateToProviderRegister());
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
  // registration logic

Future<void> register({

  required String name,
  required String email,
  required String password,
}) async {
  emit(RegisterLoading());
  try {
    await Future.delayed(Duration(seconds: 5));
    emit(RegisterSuccess());
  } catch (e) {
    emit(RegisterError(e.toString()));
  }
  
}
}

