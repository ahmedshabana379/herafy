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
import 'dart:io';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // Current user data
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // services
  List<ServiceModel> services = [];
  // governates nad regions
  List<GovernorateModel> governorates = [];
  List<RegionModel> filteredRegions = [];
  // provider data
  String? providerName;
  String? providerEmail;
  String? providerPassword;
  String? providerCategory;
  String? providerSubCategory;
  String? providerGovernateId;
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
      emit(AuthInitial());
    } else {
      selectedRole = role;
      emit(SelectRoleState(selectedRole!));
    }
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

  // --- Load current user data from cache ---
  Future<void> loadUserData() async {
    try {
      final userData = await CacheHelper.getUserData();
      if (userData != null && userData.accessToken != null) {
        _currentUser = userData;
      }
    } catch (e) {
      print('Error loading user data: $e');
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
      if (response.statusCode == 200) {
        UserModel user = UserModel.fromJson(response.data);
        _currentUser = user;
        if (user.accessToken != null) {
          await CacheHelper.saveToken(user.accessToken!);
          // حفظ بيانات المستخدم كاملة
          await CacheHelper.saveUserData(user);
        }
        emit(LoginSuccess());
      }
    } on DioException catch (e) {
      emit(LoginError(e.response?.data['message'] ?? "خطأ في تسجيل الدخول"));
    }
  }

  // registration logic for client and provider (same method for both)
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required bool isProvider,
  }) async {
    emit(RegisterLoading());
    try {
      final response = await DioHelper.postRequest(
        endPoint: AppEndPoints.register,
        data: {
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
          "isProvider": isProvider,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // For provider we only save step-1 draft, then user logs in normally.
        if (isProvider) {
          await CacheHelper.saveProviderStep1Data(
            firstName: firstName,
            lastName: lastName,
            email: email,
          );
          await CacheHelper.saveProviderProgress(0.5);
        }
        emit(RegisterSuccess(isProvider));
      }
    } on DioException catch (e) {
      String errorMessage = "فشل التسجيل";
      final data = e.response?.data;
      if (data is Map) {
        errorMessage = data['message']?.toString() ?? errorMessage;
      } else if (data is String && data.isNotEmpty) {
        errorMessage = data;
      }
      emit(RegisterError(errorMessage));
    }
  }

  // --- 3. Change Password ---
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(ChangePasswordLoading());
    try {
      final response = await DioHelper.postRequest(
        endPoint: AppEndPoints.changePassword,
        data: {"oldPassword": oldPassword, "newPassword": newPassword},
      );

      if (response.statusCode == 200) {
        emit(ChangePasswordSuccess());
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? "عفواً، كلمة المرور القديمة غير صحيحة";
      emit(ChangePasswordError(errorMessage));
    } catch (e) {
      emit(ChangePasswordError("حدث خطأ غير متوقع"));
    }
  }

  // --- 4. Logout ---
  Future<void> logout() async {
    emit(LogoutLoading());
    try {
      await DioHelper.postRequest(endPoint: AppEndPoints.logout, data: {});
    } catch (_) {
    } finally {
      _currentUser = null;
      await CacheHelper.deleteToken();
      await CacheHelper.clearAll();
      emit(LogoutSuccess());
    }
  }

  // --- 6. Provider Registration - Step 2 (Complete Provider Data) ---
Future<void> completeProviderRegistration({
  required String governorateId,
  required String regionId,
  required String workRange,
  required String address,
  required List<int> serviceIds,
  required File idCardImage,
  required File profileImage,
  required File criminalRecordImage,
}) async {
  emit(ProviderRegisterLoading());
  try {
    // Step 1: Update profile
    await DioHelper.patchRequest(
      endPoint: AppEndPoints.updateProviderProfile,
      data: {
        "GovernorateId": int.parse(governorateId),
        "RegionId": int.parse(regionId),
        "BaseLocation": {
          "Latitude": 0.0,
          "Longitude": 0.0,
          "AddressText": address,
        },
        "ServiceIds": serviceIds,
      },
    );

    // Step 2: Upload documents
    await _uploadDocument(file: profileImage,       documentType: 1, fileName: "profile_photo");
    await _uploadDocument(file: idCardImage,        documentType: 2, fileName: "national_id");
    await _uploadDocument(file: criminalRecordImage,documentType: 3, fileName: "criminal_record");

    await CacheHelper.saveProviderProgress(0.0);
    await CacheHelper.clearProviderStep1Data();
    await CacheHelper.markProviderProfileCompleted();

    emit(ProviderRegisterSuccess());
  } on DioException catch (e) {
    final data = e.response?.data;
    String message = "فشل إكمال بيانات الحرفي";
    if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    }
    emit(ProviderRegisterError(message));
  } catch (e) {
    emit(ProviderRegisterError("حدث خطأ غير متوقع"));
  }
}

Future<void> _uploadDocument({
  required File file,
  required int documentType,
  required String fileName,
}) async {
  FormData formData = FormData.fromMap({
    "DocumentType": documentType,
    "DocumentFile": await MultipartFile.fromFile(
      file.path,
      filename: '${fileName}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    ),
    "FileName": fileName,
  });

  await DioHelper.postRequest(
    endPoint: AppEndPoints.uploadDocument,
    data: formData,
  );
}

  // --- 7. Fetching Data (المحافظات والخدمات) ---
  Future<void> getGovernatesData() async {
    emit(GetRegionsLoading());
    try {
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
    filteredRegions = selectedGov.regions ?? [];
    emit(GovernorateSelectedState());
  }

  // fetch services logic

  Future<void> getServicesData() async {
    try {
      emit(GetServicesLoading());
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.services,
      );
      if (response.statusCode == 200) {
        services = (response.data as List)
            .map((s) => ServiceModel.fromJson(s))
            .toList();
        emit(GetServicesSuccess());
      }
    } catch (e) {
      emit(GetServicesError(e.toString()));
    }
  }
}
