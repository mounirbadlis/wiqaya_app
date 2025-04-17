import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthController extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();

  String? _accessToken;
  String? _refreshToken;
  String? _deviceToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get deviceToken => _deviceToken;

  Future<bool> init() async {
    setDeviceTokenFromFirebase();

    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');

    if (_refreshToken == null) {
      _accessToken = null;
      print('1');
      return true;
    } else {
      try {
        final response = await _apiClient.post(
          '/auth/refresh-token',
          data: {'refresh_token': _refreshToken},
        );
        if (response.statusCode == 403) {
          print('2');
          await logout();
          return true;
        }
        _accessToken = response.data['access_token'];
        await _storage.write(key: 'access_token', value: _accessToken);
        return false;
      } on DioException catch (e) {
        await logout();
        return true;
      }
    }
  }

  void setDeviceTokenFromFirebase() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _deviceToken = token;
        print('Device token: $_deviceToken');
        await _storage.write(key: 'device_token', value: _deviceToken);
        print('Device token saved to storage: $_deviceToken');
      }
    } catch (e) {
      print('Failed to get device token: $e');
    }
  }

  Future<void> register({
    required String firstName,
    required String familyName,
    required String birthDate,
    required int gender,
    required String email,
    required String password,
    required String phone,
    required BuildContext context,
  }) async {
    final token = await _storage.read(key: 'device_token');
    print('Device token from storage: $token');

    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'family_name': familyName,
          'birth_date': birthDate,
          'phone': phone,
          'gender': gender,
          'role': 3,
          'type': 1,
          'device_token': token
        },
      );

      if (response.statusCode == 201) {
        print('Registration successful: ${response.data}');
        _accessToken = response.data['access_token'];
        _refreshToken = response.data['refreshToken'];

        await _storage.write(key: 'access_token', value: _accessToken);
        await _storage.write(key: 'refresh_token', value: _refreshToken);
        await _storage.write(key: 'device_token', value: token);

        notifyListeners();
      } else {
        throw Exception('Unexpected response from server');
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400) {
        throw Exception(AppLocalizations.of(context)!.error_email_or_phone_exists);
      } else if (status == 500) {
        throw Exception(AppLocalizations.of(context)!.error_server);
      } else {
        throw Exception(
          AppLocalizations.of(context)!.error_connection,
        );
      }
    }
  }

  Future<void> login(String email, String password, BuildContext context) async {
    final token = await _storage.read(key: 'device_token');
    print('Device token from storage: $token');
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'device_token': token,
        },
      );
      print('Login response: ${response.data}');
      _accessToken = response.data['access_token'];
      _refreshToken = response.data['refreshToken'];

      await _storage.write(key: 'access_token', value: _accessToken);
      await _storage.write(key: 'refresh_token', value: _refreshToken);
      await _storage.write(key: 'device_token', value: _deviceToken);
      notifyListeners();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) {
        throw Exception(AppLocalizations.of(context)!.error_user_not_found);
      } else if (status == 401) {
        throw Exception(AppLocalizations.of(context)!.error_invalid_password);
      } else if (status == 500) {
        throw Exception(AppLocalizations.of(context)!.error_server);
      } else {
        throw Exception(
          AppLocalizations.of(context)!.error_connection,
        );
      }
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(
        '/auth/logout',
        data: {'refresh_token': _refreshToken, 'device_token': _deviceToken},
      );
    } catch (_) {}

    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'device_token');

    _accessToken = null;
    _refreshToken = null;
    _deviceToken = null;

    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
    return _accessToken != null;
  }
}
