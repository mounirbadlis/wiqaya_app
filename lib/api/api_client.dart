import 'package:dio/dio.dart';
import 'package:wiqaya_app/models/user.dart';
import 'package:wiqaya_app/services/secure_storage_service.dart';

class ApiClient {
  final Dio dio = Dio();
  final _secureStorage = SecureStorageService();

  ApiClient() {
    dio.options.baseUrl = 'http://192.168.155.165:3001';
    // dio.options.baseUrl = 'http://10.40.10.225:3001';
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.validateStatus = (status) => status != null && status >= 200 && status < 300;

    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read('access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        // onError: (DioException error, handler) async {
        //   if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
        //     // Token might be expired
        //     print('error refresh token: ${error.response?.data}');
        //     final refreshToken = await _secureStorage.read('refresh_token');
        //     if (refreshToken != null) {
        //       try {
        //         final refreshResponse = await dio.post(
        //           '/auth/refresh-token',
        //           data: {'refresh_token': refreshToken},
        //         );
        //         User.user = User.fromJson(refreshResponse.data['user']);
        //         final newToken = refreshResponse.data['access_token'];
        //         final newRefresh = refreshResponse.data['refresh_token'];

        //         await _secureStorage.write('access_token', newToken);
        //         await _secureStorage.write('refresh_token', newRefresh);

        //         // Retry original request with new token
        //         final newRequest = error.requestOptions;
        //         newRequest.headers['Authorization'] = 'Bearer $newToken';

        //         final cloned = await dio.fetch(newRequest);
        //         return handler.resolve(cloned);
        //       } catch (e) {
        //         // Refresh failed, logout or redirect
        //         return handler.reject(error);
        //       }
        //     }
        //   // }
        //   return handler.next(error);
        // }
        // },
      ),
    );
  }

  Future<Response> get(String path, {dynamic data}) => dio.get(path, data: data);
  Future<Response> post(String path, {dynamic data}) => dio.post(path, data: data);
  Future<Response> patch(String path, {dynamic data}) => dio.patch(path, data: data);
}
