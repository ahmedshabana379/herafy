
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CacheHelper {
static final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  )
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

}