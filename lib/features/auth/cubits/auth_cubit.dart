import 'package:dio/dio.dart';
import 'package:herafy/core/networks/cache_helper.dart';
import 'package:herafy/core/networks/dio_helpers.dart';
import 'package:herafy/core/networks/end_points.dart';
import 'package:herafy/core/resourses/constants.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/features/auth/models/gov_and_regions_model.dart';
import 'package:herafy/features/auth/models/services_model.dart';
import 'package:herafy/features/auth/models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  // services
  List<ServiceModel> services =[];
  // governates nad regions
  List<GovernorateModel> governorates = [];
  List<RegionModel> filteredRegions = [];
  // provider data
  String? providerName;
  String? providerEmail;
  String? providerPassword;
  String? providerCategory;
  String? providerSubCategory;
  String? providerCity;
  String? providerRegionId;
  String? provideraddress;
  String? providerRange;
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
    emit(SelectRoleState(selectedRole!));
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
  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());
    try {
      final response = await DioHelper.postRequest(
        endPoint: AppEndPoints.login,
        data: {"email": email, "password": password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        UserModel user = UserModel.fromJson(response.data);
        if (user.accessToken != null) {
          await CacheHelper.saveToken(user.accessToken!);
        }
        emit(LoginSuccess());
      } else {
        emit(LoginError("فشل تسجيل الدخول: تأكد من البيانات"));
      }
    } on DioException catch (e) {
      String message = e.response?.data['message'] ?? "حدث خطأ في الاتصال";
      emit(LoginError(message));
    } catch (e) {
      emit(LoginError("حدث خطأ غير متوقع: ${e.toString()}"));
    }
  }
  // registration logic for client

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

  // registration logic for provider
  Future<void> providerRegister() async {
    emit(ProviderRegisterLoading());
    try {
      await Future.delayed(Duration(seconds: 5));
      emit(ProviderRegisterSuccess());
    } catch (e) {
      emit(ProviderRegisterError(e.toString()));
    }
  }

  // governates and regions fetch logic
  Future<void> getGovernatesData() async {
    try {
      emit(GetRegionsLoading());
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.regionsAndGavernates,
      );
      if (response.statusCode == 200) {
        governorates = (response.data as List)
            .map((e) => GovernorateModel.fromJson(e))
            .toList();
        emit(GetRegionsSuccess());
      }
    } catch (e) {
      emit(GetRegionsError(e.toString()));
    }
  }

  // 2. ميثود اختيار المحافظة (بناديها لما الدروب داون تتغير)
  void onGovernateSelectedState(GovernorateModel selectedGov) {
    if (selectedGov != null) {
      filteredRegions = selectedGov.regions ?? [];
      emit(GovernorateSelectedState());
    }
  }

  // fetch services logic

  Future<void> getServicesData() async {
    try {
      emit(GetServicesLoading());
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.services,
      );
      if (response.statusCode ==200) {
        services=(response.data as List).map((s)=>ServiceModel.fromJson(s)).toList();
        emit(GetServicesSuccess());
      }
    } catch (e) {
      emit(GetServicesError(e.toString()));
    }
  }
}
