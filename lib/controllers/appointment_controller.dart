import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/models/appointment.dart';
import 'package:wiqaya_app/models/user.dart';
import 'package:wiqaya_app/models/vaccine.dart';
import 'package:wiqaya_app/models/vaccination_center.dart';

class AppointmentController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Appointment> appointments = [];
  Appointment? selectedAppointment;
  Appointment? newAppointment;
  List<DateTime> availableDays = [];
  List<VaccinationCenter> availableCenters = [];
  List<Map<String, dynamic>> centersWithDistance = [];
  bool isLoading = true;
  bool hasError = false;

  bool isAvailableCentersLoading = true;
  bool isAvailableCentersError = false;

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

  Future<void> getAvailableDaysForVaccine(String id) async {
    try {
      isLoading = true;
      hasError = false;
      notifyListeners();

      final response = await _apiClient.get('/appointments/available_days/$id');

      // Parse the response into a list of DateTime
      availableDays = response.data.map<DateTime>((e) => DateTime.parse(e as String)).toList();
    } catch (e) {
      print('getAvailableDaysForVaccine failed: $e');
      availableDays = [];
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAvailableCentersForDay(Vaccine vaccine, DateTime date, Point userLocation) async {
    try {
      isAvailableCentersLoading = true;
      isAvailableCentersError = false;
      notifyListeners();

      final response = await _apiClient.get('/appointments/available_centers/${vaccine.id}/${date.toIso8601String()}');

      availableCenters = VaccinationCenter.centersFromJson(response.data);
      centersWithDistance =
          availableCenters.map((center) => {
                'center': center,
                'distance': Geolocator.distanceBetween(center.latitude!, center.longitude!, userLocation.coordinates.lat.toDouble(), userLocation.coordinates.lng.toDouble()),
              }).toList();

      centersWithDistance.sort((a, b) => a['distance']!.compareTo(b['distance']!));
      print(centersWithDistance);
    } catch (e) {
      print('getAvailableCentersForDay failed: $e');
      availableCenters = [];
      isAvailableCentersError = true;
    } finally {
      isAvailableCentersLoading = false;
      notifyListeners();
    }
  }
}
