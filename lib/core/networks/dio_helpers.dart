import 'package:dio/dio.dart';
import 'package:herafy/core/networks/end_points.dart';

class DioHelper {
  static Dio? dio;
  static void initDio() {
    dio = Dio(
      BaseOptions(
        receiveDataWhenStatusError: true,
        baseUrl: AppEndPoints.baseUrl,
      ),
    );
  }

  static Future<Response> getRequest({required String endPoint}) async {
    try {
      Response response = await dio!.get(endPoint);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> postRequest({required String endPoint, required dynamic data,}) async {
    try {
      Response response = await dio!.post(endPoint, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
