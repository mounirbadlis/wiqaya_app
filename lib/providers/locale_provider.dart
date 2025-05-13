import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wiqaya_app/services/secure_storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  final _secureStorage = SecureStorageService();
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final code = await _secureStorage.read('locale');
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
    await _secureStorage.write('locale', locale.languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    await _secureStorage.write('locale', locale.languageCode);
  }

}
