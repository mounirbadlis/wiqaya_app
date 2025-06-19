import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/models/vaccination_center.dart';

class CenterController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool isLoading = false;
  bool hasError = false;
  List<VaccinationCenter> centers = [];
  VaccinationCenter? selectedCenter;

  Future<void> getCenters() async {
    try {
      isLoading = true;
      final response = await _apiClient.get('/centers');
      centers = VaccinationCenter.centersFromJson(response.data);
    } catch (e) {
      centers = [];
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
