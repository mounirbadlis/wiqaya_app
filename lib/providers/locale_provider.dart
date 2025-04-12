import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final code = await _storage.read(key: 'locale');
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> changeLocale() async {
    if(locale.languageCode == 'en') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
    await _storage.write(key: 'locale', value: locale.languageCode);
  }
}
