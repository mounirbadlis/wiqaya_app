import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wiqaya_app/models/user.dart';
import 'package:wiqaya_app/services/secure_storage_service.dart';

class AuthController extends ChangeNotifier {
  final _secureStorage = SecureStorageService();
  final ApiClient _apiClient = ApiClient();

  String? _accessToken;
  String? _refreshToken;
  String? _deviceToken;
  User? _user;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get deviceToken => _deviceToken;
  User? get user => _user;

  Future<bool> init() async {
    setDeviceTokenFromFirebase();

    _accessToken = await _secureStorage.read('access_token');
    _refreshToken = await _secureStorage.read('refresh_token').then((value) {
      print('refresh token: $value');
      return value;
    });
    print('refresh token: $_refreshToken');

    if (_refreshToken == null) {
      _accessToken = null;
      return true;
    } else {
      try {
        final response = await _apiClient.post(
          '/auth/refresh-token',
          data: {'refresh_token': _refreshToken},
        );
        if (response.statusCode == 403) {
          await logout();
          return true;
        }
        User.user = User.fromJson(response.data['user']);
        _user = User.fromJson(response.data['user']);
        _accessToken = response.data['access_token'];
        await _secureStorage.write('access_token', _accessToken!);
        return false;
      } on DioException catch (e) {
        print('refresh token failed: $e');
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
        await _secureStorage.write('device_token', _deviceToken!);
      }
    } catch (e) {
      print('Failed to get device token: $e');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String familyName,
    required String birthDate,
    required String phone,
    required int gender,
    required String bloodType,
    required BuildContext context,
  }) async {
    final token = await _secureStorage.read('device_token');
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
          'blood_type': bloodType,
          'role': 3,
          'type': 1,
          'device_token': token
        },
      );

      if (response.statusCode == 201) {
        print('Registration successful: ${response.data}');
        _user = User.fromJson(response.data['user']);
        User.user = User.fromJson(response.data['user']);
        _accessToken = response.data['accessToken'];
        _refreshToken = response.data['refreshToken'];
        await _secureStorage.write('access_token', _accessToken!);
        await _secureStorage.write('refresh_token', _refreshToken!);
        await _secureStorage.write('device_token', token!);

        notifyListeners();
      } else {
        print('Unexpected response from server: ${response.data}');
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
    final token = await FirebaseMessaging.instance.getToken();
    _deviceToken = token;
    print('Device token from storage: $token');
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'device_token': _deviceToken,
        },
      );
      _user = User.fromJson(response.data['user']);
      User.user = _user;
      _accessToken = response.data['accessToken'];
      _refreshToken = response.data['refreshToken'];

      await _secureStorage.write('access_token', _accessToken!);
      await _secureStorage.write('refresh_token', _refreshToken!);
      await _secureStorage.write('device_token', _deviceToken!);
      notifyListeners();
    } on DioException catch (e) {
      print('Error from server: ${e.response?.data}');
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

    await _secureStorage.delete('access_token');
    await _secureStorage.delete('refresh_token');
    await _secureStorage.delete('device_token');

    _accessToken = null;
    _refreshToken = null;
    _deviceToken = null;
    
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    _accessToken = await _secureStorage.read('access_token');
    _refreshToken = await _secureStorage.read('refresh_token');
    return _accessToken != null;
  }
}
