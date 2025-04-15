import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wiqaya_app/api/api_client.dart';

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
    await setDeviceTokenFromFirebase();

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

  Future<void> setDeviceTokenFromFirebase() async {
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

  Future<void> login(String email, String password) async {
    final token = await _storage.read(key: 'device_token');
    print('Device token from storage: $token');
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'device_token': deviceToken,
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
      if(status == 404) {
        throw Exception('User not found');
      } else if(status == 401) {
        throw Exception('Invalid password');
      } else if(status == 500) {
        throw Exception('Server error, please try again later');
      } else {
        throw Exception('Connection error, please check your internet connection');
      }
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(
        '/auth/logout',
        data: {'refresh_token': _refreshToken},
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
