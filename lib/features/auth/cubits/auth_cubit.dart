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
      // Handle any errors during loading user data
    }
  }

  // login logic
  // Future<void> login({required String email, required String password}) async {
  //   emit(LoginLoading());
  //   try {
  //     final response = await DioHelper.postRequest(
  //       endPoint: AppEndPoints.login,
  //       data: {"email": email, "password": password},
  //     );
  //     if (response.statusCode == 200) {
  //       UserModel user = UserModel.fromJson(response.data);

  //       _currentUser = user;

  //       if (user.firstName == null && user.fullName.isNotEmpty) {
  //         final parts = user.fullName.trim().split(' ');
  //         _currentUser = user.copyWith(
  //           firstName: parts.first,
  //           lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
  //         );
  //       }

  //       if (user.accessToken != null) {
  //         await CacheHelper.saveToken(user.accessToken!);
  //         await CacheHelper.saveUserData(user);
  //         emit(UserDataUpdated());
  //       }

  //       // ✅ التحقق: لو المستخدم فني، اجيب بياناته الكاملة (بما فيها الكريديت)
  //       if (_currentUser!.isProvider) {
  //         await getProviderProfile(); // <--- دي اللي تجيب الكريديت
  //       } else {
  //         await getUserProfile(); // للعميل العادي
  //       }

  //       emit(LoginSuccess());
  //     }
  //   } on DioException catch (e) {
  //     emit(LoginError(e.response?.data['message'] ?? "خطأ في تسجيل الدخول"));
  //   }
  // }

  // في AuthCubit.dart

  // أضف هذه الدالة
  Future<void> getProviderCredits() async {
    try {
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.providerGetsHisProfile,
      );

      if (response.statusCode == 200 && _currentUser != null) {
        final data = response.data;
        final creditsValue = data['credits']?.toInt() ?? 0;
        final fullName = data['name'] ?? ""; // "فني احمد"

        print("📛 Full name from API: $fullName");

        // ✅ قسم الاسم إلى firstName و lastName
        String firstName = fullName;
        String lastName = "";

        if (fullName.contains(' ')) {
          final parts = fullName.split(' ');
          firstName = parts.first;
          lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        }

        _currentUser = _currentUser!.copyWith(
          credits: creditsValue,
          firstName: firstName,
          lastName: lastName,
          pictureUrl: data['pictureUrl'],
        );

        print("👤 FirstName: $firstName, LastName: $lastName");
        print("💰 Credits: $creditsValue");

        await CacheHelper.saveUserData(_currentUser!);
        emit(UserDataUpdated());
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  // -------------------------------------------------------------------
  // ثم عدل دالة login - أضف استدعاء getProviderCredits
  // -------------------------------------------------------------------

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

        if (user.firstName == null && user.fullName.isNotEmpty) {
          final parts = user.fullName.trim().split(' ');
          _currentUser = user.copyWith(
            firstName: parts.first,
            lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
          );
        }

        if (user.accessToken != null) {
          await CacheHelper.saveToken(user.accessToken!);
          await CacheHelper.saveUserData(user);
        }

        // ✅ جلب البيانات كاملة قبل ما تبعث LoginSuccess
        if (_currentUser!.isProvider) {
          await getProviderCredits(); // دي هتحدث الصورة والاسم والكريديت
          await getProviderProfile(); // دي هتحدث باقي البيانات
        } else {
          await getUserProfile();
        }

        // ✅ بعد ما كل البيانات تجابت, ابعث نجاح
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
        if (isProvider) {
          await CacheHelper.saveProviderStep1Data(
            firstName: firstName,
            lastName: lastName,
            email: email,
          );
          await CacheHelper.saveProviderProgress(0.5);
        }
        _currentUser = UserModel(
          firstName: firstName,
          lastName: lastName,
          email: email,
          isProviderFromServer: isProvider,
          roles: isProvider ? ["Provider"] : ["Client"],
          status: 0,
        );
        await CacheHelper.saveUserData(_currentUser!);
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
    required double latitude,
    required double longitude,
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
            "Latitude": latitude,
            "Longitude": longitude,
            "AddressText": address,
          },
          "ServiceIds": serviceIds,
        },
      );

      // Step 2: Upload documents
      await _uploadDocument(
        file: profileImage,
        documentType: 1,
        fileName: "profile_photo",
      );
      await _uploadDocument(
        file: idCardImage,
        documentType: 2,
        fileName: "national_id",
      );
      await _uploadDocument(
        file: criminalRecordImage,
        documentType: 3,
        fileName: "criminal_record",
      );

      await CacheHelper.saveProviderProgress(0.0);
      await CacheHelper.clearProviderStep1Data();
      await CacheHelper.markProviderProfileCompleted();
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(status: 1); // UnderReview
        await CacheHelper.saveUserData(updatedUser);
        _currentUser = updatedUser;
        print(
          "================${_currentUser!.status} =========================",
        );
      }
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

  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required int gender,
    required int governorateId,
    required int regionId,
    File? profileImage,
    DateTime? birthDate,
  }) async {
    emit(UpdateProfileLoading());
    try {
      // ✅ دايماً FormData لأن الـ API بياخد form-data
      final formDataMap = <String, dynamic>{
        "FirstName": firstName,
        "LastName": lastName,
        "GovernorateId": governorateId,
        "RegionId": regionId,
        "Gender": gender,
        "PhoneNumbers": [phoneNumber], // ✅ array
        if (birthDate != null)
          "dateOfBirth":
              "${birthDate.year}-${birthDate.month}-${birthDate.day}",
        if (profileImage != null)
          "Picture": await MultipartFile.fromFile(
            profileImage.path,
            filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
      };

      final response = await DioHelper.putRequest(
        endPoint: AppEndPoints.updateClientProfile,
        data: FormData.fromMap(formDataMap),
      );

      // ✅ تحديث الـ cache
      if (_currentUser != null) {
        String? newPictureUrl = _currentUser!.pictureUrl;

        // لو السيرفر رجّع pictureUrl في الـ response خده منه
        if (response.data is Map && response.data['pictureUrl'] != null) {
          newPictureUrl = response.data['pictureUrl'];
        }

        final updatedUser = _currentUser!.copyWith(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          gender: gender,
          governorateId: governorateId,
          regionId: regionId,

          isProfileComplete: true,
          pictureUrl: newPictureUrl,
          status: _currentUser!.status == 0 ? 5 : _currentUser!.status,
        );
        await CacheHelper.saveUserData(updatedUser);
        _currentUser = updatedUser;
      }
      emit(UserDataUpdated());
      emit(UpdateProfileSuccess());
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = "فشل تحديث البيانات";
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      } else if (data is String && data.isNotEmpty) {
        message = data;
      }
      emit(UpdateProfileError(message));
    } catch (e) {
      emit(UpdateProfileError("حدث خطأ غير متوقع"));
    }
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

    // check provider status after fetching services (in case user is provider and we need to show them the status)
    void checkProviderStatus() async {
      final user = _currentUser ?? await CacheHelper.getUserData();
      if (user == null || !user.isProvider) return;

      switch (user.status) {
        case 1:
          emit(ProviderUnderReviewState());
          break;
        case 2:
          emit(ProviderApprovedState());
          break;
        case 3:
          emit(ProviderRejectedState());
          break;
      }
    }
  }

  Future<void> getUserProfile() async {
    try {
      // استخدم الـ EndPoint المناسبة (Client أو Provider)
      final endPoint = AppEndPoints.getUserData;

      final response = await DioHelper.getRequest(endPoint: endPoint);

      if (response.statusCode == 200) {
        final profileData = response.data;

        _currentUser = _currentUser?.copyWith(
          firstName: profileData['firstName'],
          lastName: profileData['lastName'],
          gender: profileData['gender'],
          pictureUrl: profileData['pictureUrl'],
          governorateId: profileData['governorateId'],
          regionId: profileData['regionId'],
          phoneNumber: (profileData['phoneNumbers'] as List).isNotEmpty
              ? profileData['phoneNumbers'][0]
              : null,
        );

        // حفظ النسخة الكاملة في الكاش
        await CacheHelper.saveUserData(_currentUser!);
        emit(UserDataUpdated()); // عشان الـ Drawer يحس بالتغيير
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  // --- ميثود جلب بروفايل الفني وتحديث الكريديت ---
  Future<void> getProviderProfile() async {
    try {
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.providerGetsHisProfile,
      );

      if (response.statusCode == 200 && _currentUser != null) {
        final profileData = response.data;

        _currentUser = _currentUser!.copyWith(
          firstName: profileData['firstName'] ?? _currentUser!.firstName,
          lastName: profileData['lastName'] ?? _currentUser!.lastName,
          pictureUrl: profileData['pictureUrl'] ?? _currentUser!.pictureUrl,
          phoneNumber: profileData['phoneNumber'] ?? _currentUser!.phoneNumber,
          governorateId: profileData['governorateId'],
          regionId: profileData['regionId'],
          status: profileData['status'] ?? _currentUser!.status,
        );

        await CacheHelper.saveUserData(_currentUser!);

        // ✅ برضه إرسال حدث للتحديث
        emit(UserDataUpdated());
      }
    } catch (e) {
      print("Error fetching provider profile: $e");
    }
  }

  // Future<void> appStarted() async {
  //   await loadUserData();
  //   if (_currentUser != null) {
  //     // ✅ نفس المنطق هنا برضه
  //     if (_currentUser!.isProvider) {
  //       await getProviderProfile();
  //     } else {
  //       await getUserProfile();
  //     }
  //   }
  // }
}
