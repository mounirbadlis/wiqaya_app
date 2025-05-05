import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio = Dio();
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    dio.options.baseUrl = 'http://192.168.155.165:3001';
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
            // Token might be expired
            final refreshToken = await _storage.read(key: 'refresh_token');
            if (refreshToken != null) {
              try {
                final refreshResponse = await dio.post(
                  '/auth/refresh-token',
                  data: {'refresh_token': refreshToken},
                );

                final newToken = refreshResponse.data['access_token'];
                final newRefresh = refreshResponse.data['refresh_token'];

                await _storage.write(key: 'access_token', value: newToken);
                await _storage.write(key: 'refresh_token', value: newRefresh);

                // Retry original request with new token
                final newRequest = error.requestOptions;
                newRequest.headers['Authorization'] = 'Bearer $newToken';

                final cloned = await dio.fetch(newRequest);
                return handler.resolve(cloned);
              } catch (e) {
                // Refresh failed, logout or redirect
                return handler.reject(error);
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path) => dio.get(path);
  Future<Response> post(String path, {dynamic data}) =>
      dio.post(path, data: data);
}
