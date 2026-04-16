import 'package:dio/dio.dart';
import 'package:herafy/core/networks/cache_helper.dart';
import 'package:herafy/core/networks/end_points.dart';

class DioHelper {
  static Dio? dio;

  static void initDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppEndPoints.baseUrl,
        receiveDataWhenStatusError: true,
        // بنضيف الهيدرز الأساسية هنا
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  // ميثود مساعدة لجلب التوكن ووضعه في الهيدر
  static Future<void> _setAuthHeader() async {
    String? token = await CacheHelper.getToken();
    if (token != null) {
      dio!.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio!.options.headers.remove('Authorization');
    }
  }

  static Future<Response> getRequest({
    required String endPoint,
    Map<String, dynamic>? query,
  }) async {
    await _setAuthHeader(); // تأكد إن التوكن موجود قبل الطلب
    return await dio!.get(endPoint, queryParameters: query);
  }

  static Future<Response> postRequest({
    required String endPoint,
    required dynamic data,
    Type? contentType,
    Map<String, dynamic>? query,
  }) async {
    await _setAuthHeader(); // تأكد إن التوكن موجود قبل الطلب

    // إذا كانت البيانات FormData، احذف Content-Type header
    if (data is FormData) {
      dio!.options.headers.remove('Content-Type');
    } else {
      dio!.options.headers['Content-Type'] = 'application/json';
    }

    return await dio!.post(endPoint, data: data, queryParameters: query);
  }

 static Future<Response> putRequest({
    required String endPoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    await _setAuthHeader(); // ضروري عشان التوكن

    // هندلة الـ Content-Type لو فيه صور أو ملفات
    if (data is FormData) {
      dio!.options.headers.remove('Content-Type');
    } else {
      dio!.options.headers['Content-Type'] = 'application/json';
    }

    return await dio!.put(
      endPoint,
      data: data,
      queryParameters: queryParameters,
    );
  }

  static Future<Response> patchRequest({
    required String endPoint,
    dynamic data,
  }) async {
    await _setAuthHeader(); // ضروري عشان التوكن

    if (data is FormData) {
      dio!.options.headers.remove('Content-Type');
    } else {
      dio!.options.headers['Content-Type'] = 'application/json';
    }

    return await dio!.patch(endPoint, data: data);
  }
  static Future<Response> deleteRequest({
  required String endPoint,
  Map<String, dynamic>? queryParameters,
}) async {
  await _setAuthHeader();
  return await dio!.delete(endPoint, queryParameters: queryParameters);
}
}
