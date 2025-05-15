import 'package:flutter/material.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/models/appointment.dart';

class AppointmentController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Appointment> appointments = [];
  Appointment? selectedAppointment;
  Appointment? newAppointment;
  bool isLoading = true;
  bool hasError = false;

  Future<void> getAppointments(String id) async {
    try {
      isLoading = true;
      hasError = false;
      notifyListeners();
      final response = await _apiClient.get('/appointments/$id');
      appointments = Appointment.appointmentsFromJson(response.data);
    } catch (e) {
      print('getAppointments failed: $e');
      appointments = [];
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
