import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/models/appointment.dart';
import 'package:wiqaya_app/models/user.dart';
import 'package:wiqaya_app/models/vaccine.dart';
import 'package:wiqaya_app/models/vaccination_center.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      centersWithDistance[0]['nearest'] = true;
    } catch (e) {
      print('getAvailableCentersForDay failed: $e');
      availableCenters = [];
      isAvailableCentersError = true;
    } finally {
      isAvailableCentersLoading = false;
      notifyListeners();
    }
  }

  // Future<void> bookAppointment(String individualId, String vaccineId, DateTime date, String centerId, BuildContext context) async {
  //   try {
  //     final response = await _apiClient.post('/appointments', data: {
  //       'individual_id': individualId,
  //       'vaccine_id': vaccineId,
  //       'date': date.add(const Duration(days: 1)).toIso8601String(),
  //       'center_id': centerId,
  //     });
  //     print('bookAppointment response: ${response.data}');
  //     if(response.statusCode == 201) {
  //       newAppointment = Appointment.fromJson(response.data);
  //     }
  //   } on DioException catch (e) {
  //     print('bookAppointment failed: $e');
  //     if(e.response?.statusCode == 400) {
  //       throw Exception(AppLocalizations.of(context)!.no_available_slots);
  //     } else if(e.response?.statusCode == 500) {
  //       throw Exception(AppLocalizations.of(context)!.error_server);
  //     } else {
  //       throw Exception(AppLocalizations.of(context)!.error_connection);
  //     }
  //   }
  // }
  Future<void> bookAppointment(String individualId, String vaccineId, DateTime date, String centerId, BuildContext context) async {
  try {
    final response = await _apiClient.post('/appointments', data: {
      'individual_id': individualId,
      'vaccine_id': vaccineId,
      'date': date.toIso8601String(),
      'center_id': centerId,
    });
    print('bookAppointment response: ${response.data}');
    if(response.statusCode == 201) {
      newAppointment = Appointment.fromJson(response.data);
    }
  } on DioException catch (e) {
    print('bookAppointment failed: $e');
    // Print more detailed error information
    print('Error response data: ${e.response?.data}');
    print('Error response status code: ${e.response?.statusCode}');
    
    if(e.response?.statusCode == 400) {
      throw Exception(AppLocalizations.of(context)!.no_available_slots);
    } else if(e.response?.statusCode == 500) {
      throw Exception(AppLocalizations.of(context)!.error_server);
    } else {
      throw Exception(AppLocalizations.of(context)!.error_connection);
    }
  }
}
}
