import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/controllers/auth_controller.dart';
import 'package:wiqaya_app/models/vaccine.dart';

class VaccineController extends ChangeNotifier {
  ApiClient _apiClient = ApiClient();
  List<Vaccine> vaccines = [];
  Vaccine? selectedVaccine;
  bool isLoading = false;
  bool hasError = false;

  Future<void> getVaccines() async {
  try {
    isLoading = true;
    hasError = false;
    notifyListeners();

    final response = await _apiClient.get('/vaccines');

    final List<dynamic> data = response.data;
    for (var vaccine in data) {
      if (vaccine['required_ages'] != null) {
        vaccine['required_ages'] = (vaccine['required_ages'] as List)
            .map((e) => e['age'] as int)
            .toList();
      }
      if (vaccine['side_effects'] != null) {
        vaccine['side_effects'] = (vaccine['side_effects'] as List)
            .map((e) => e['effect'] as String)
            .toList();
      }
    }

    vaccines = Vaccine.vaccinesFromJson(data);
  } catch (e) {
    vaccines = [];
    if(e is DioException) {
      if(e.response?.statusCode == 404) {
        hasError = false;
      } else {
        hasError = true;
      }
    } else {
      hasError = true;
    }
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
}
