import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:herafy/features/auth/models/user_model.dart';
import 'dart:convert';

class CacheHelper {
  static final storage = FlutterSecureStorage(
    // ignore: deprecated_member_use
    aOptions: const AndroidOptions(encryptedSharedPreferences: true),
  );
  // get token
  static Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  // save token
  static Future<void> saveToken(String token) async {
    return await storage.write(key: 'token', value: token);
  }

  //   delete token
  static Future<void> deleteToken() async {
    return await storage.delete(key: 'token');
  }

  // save user data
  static Future<void> saveUserData(UserModel user) async {
    try {
      await storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // get user data
  static Future<UserModel?> getUserData() async {
    try {
      final userData = await storage.read(key: 'user_data');
      if (userData != null) {
        return UserModel.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Save provider registration step 1 data (basic info)
  static Future<void> saveProviderStep1Data({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      };
      await storage.write(key: 'provider_step1_data', value: jsonEncode(data));
      await storage.write(key: 'provider_needs_completion', value: 'true');
    } catch (e) {
      print('Error saving provider step 1 data: $e');
    }
  }

  // Get provider registration step 1 data
  static Future<Map<String, dynamic>?> getProviderStep1Data() async {
    try {
      final data = await storage.read(key: 'provider_step1_data');
      if (data != null) {
        return jsonDecode(data);
      }
      return null;
    } catch (e) {
      print('Error getting provider step 1 data: $e');
      return null;
    }
  }

  // Whether provider still needs to complete step 2
  static Future<bool> isProviderPendingCompletion() async {
    try {
      final value = await storage.read(key: 'provider_needs_completion');
      return value == 'true';
    } catch (e) {
      print('Error reading provider pending completion flag: $e');
      return false;
    }
  }

  // Clear provider step 1 draft after completing full profile
  static Future<void> clearProviderStep1Data() async {
    try {
      await storage.delete(key: 'provider_step1_data');
      await storage.delete(key: 'provider_needs_completion');
    } catch (e) {
      print('Error clearing provider step 1 data: $e');
    }
  }

  // Save provider registration progress
  static Future<void> saveProviderProgress(double progress) async {
    try {
      await storage.write(key: 'provider_progress', value: progress.toString());
    } catch (e) {
      print('Error saving provider progress: $e');
    }
  }

  // Get provider registration progress
  static Future<double> getProviderProgress() async {
    try {
      final progress = await storage.read(key: 'provider_progress');
      return progress != null ? double.parse(progress) : 0.0;
    } catch (e) {
      print('Error getting provider progress: $e');
      return 0.0;
    }
  }

  // Mark provider profile as completed
  static Future<void> markProviderProfileCompleted() async {
    try {
      await storage.write(key: 'provider_profile_completed', value: 'true');
    } catch (e) {
      print('Error marking provider profile as completed: $e');
    }
  }

  // Check if provider profile is completed
  static Future<bool> isProviderProfileCompleted() async {
    try {
      final value = await storage.read(key: 'provider_profile_completed');
      return value == 'true';
    } catch (e) {
      print('Error checking provider profile completion: $e');
      return false;
    }
  }

  // clear all data
  static Future<void> clearAll() async {
    await storage.deleteAll();
  }
}
