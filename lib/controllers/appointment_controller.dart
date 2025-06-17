import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/models/appointment.dart';
import 'package:wiqaya_app/models/postponed_vaccination.dart';
import 'package:wiqaya_app/models/recommendation_result.dart';
import 'package:wiqaya_app/models/vaccine.dart';
import 'package:wiqaya_app/models/vaccination_center.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppointmentController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Appointment> appointments = [];
  Appointment? selectedAppointment;
  Appointment? newAppointment;
  PostponedVaccination? postponedVaccination;
  List<DateTime> availableDays = [];
  List<VaccinationCenter> availableCenters = [];
  List<RecommendationResult> recommendedCenters = [];
  List<Map<String, dynamic>> centersWithDistance = [];
  bool isLoading = true;
  bool hasError = false;

  bool isTodayAppointmentsLoading = true;
  bool isTodayAppointmentsError = false;

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

  Future<void> getTodayAppointments(String id) async {
    try {
      isTodayAppointmentsLoading = true;
      isTodayAppointmentsError = false;
      notifyListeners();
      final response = await _apiClient.get('/appointments/today/$id');
      appointments = Appointment.appointmentsFromJson(response.data);
    } catch (e) {
      print('getTodayAppointments failed: $e');
      appointments = [];
      if(e is DioException) {
        if(e.response?.statusCode == 404) {
          isTodayAppointmentsError = false;
        } else {
          isTodayAppointmentsError = true;
        }
      } else {
        isTodayAppointmentsError = true;
      }
    } finally {
      isTodayAppointmentsLoading = false;
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
      if(centersWithDistance.isNotEmpty) {
        centersWithDistance[0]['nearest'] = true;
      }
    } catch (e) {
      print('getAvailableCentersForDay failed: $e');
      availableCenters = [];
      if(e is DioException) {
        if(e.response?.statusCode == 404) {
          isAvailableCentersError = false;
        } else {
          isAvailableCentersError = true;
        }
      } else {
        isAvailableCentersError = true;
      }
    } finally {
      isAvailableCentersLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAvailableCentersAutomatically(String vaccineId, DateTime date, Point userLocation) async {
    try {
      isAvailableCentersLoading = true;
      isAvailableCentersError = false;
      notifyListeners();

      final response = await _apiClient.get('/appointments/available_centers_automatically/$vaccineId/${date.toIso8601String()}');

      recommendedCenters = RecommendationResult.fromJsonList(response.data);
      centersWithDistance =
      recommendedCenters.map((center) => {
        'center': center,
        'distance': Geolocator.distanceBetween(center.latitude, center.longitude, userLocation.coordinates.lat.toDouble(), userLocation.coordinates.lng.toDouble()),
        }).toList();
      print('centersWithDistance: $centersWithDistance');
      centersWithDistance.sort((a, b) => a['distance']!.compareTo(b['distance']!));
      if(centersWithDistance.isNotEmpty) {
        centersWithDistance[0]['nearest'] = true;
      }
    } on DioException catch (e) {
      print('getAvailableCentersAutomatically failed: $e');
      recommendedCenters = [];
      if (e.response?.statusCode == 404) {
        isAvailableCentersError = false;
      } else {
        isAvailableCentersError = true;
      }
    } finally {
      isAvailableCentersLoading = false;
      notifyListeners();
    }
  }

  Future<void> bookAppointment(String individualId, String vaccineId, DateTime date, String centerId, int type, BuildContext context) async {
    try {
      final response = await _apiClient.post('/appointments', data: {
        'individual_id': individualId,
        'vaccine_id': vaccineId,
        'date': date.toIso8601String(),
        'center_id': centerId,
        'type': type,
        'manual': true,
      });
      if(response.statusCode == 201) {
        newAppointment = Appointment.fromJson(response.data);
      }
    } on DioException catch (e) {
      print('bookAppointment failed: $e');
      if(e.response?.statusCode == 400) {
        throw Exception(AppLocalizations.of(context)!.no_available_slots);
      } else if(e.response?.statusCode == 422) {
        throw Exception(AppLocalizations.of(context)!.already_taken);
      } else if(e.response?.statusCode == 500) {
        throw Exception(AppLocalizations.of(context)!.error_server);
      } else {
        throw Exception(AppLocalizations.of(context)!.error_connection);
      }
    }
  }

  Future<void> postponeAppointment(String individualId, String vaccineId, int reason, DateTime retryDate, String? childFirstName, String? childFamilyName, vaccineName, int type, BuildContext context) async {
    try {
      final response = await _apiClient.post('/postponing', data: {
        'individual_id': individualId,
        'vaccine_id': vaccineId,
        'reason': reason,
        'retry_date': retryDate.toIso8601String(),
        'child_first_name': childFirstName,
        'child_family_name': childFamilyName,
        'vaccine_name': vaccineName,
        'type': type,
      });
      if(response.statusCode == 201) {
        postponedVaccination = PostponedVaccination.fromJson(response.data);
      }
    } on DioException catch (e) {
      if(e.response?.statusCode == 500) {
        throw Exception(AppLocalizations.of(context)!.error_server);
      } else {
        throw Exception(AppLocalizations.of(context)!.error_connection);
      }
    }
  }

  Future<void> cancelAppointment(BuildContext context) async {
    try {
      final response = await _apiClient.patch('/appointments', data: {
        'id': selectedAppointment?.id,
        'status': 3,
      });
      if(response.statusCode == 204) {
        selectedAppointment = null;
      }
    } on DioException catch (e) {
      if(e.response?.statusCode == 500) {
        throw Exception(AppLocalizations.of(context)!.error_server);
      } else {
        throw Exception(AppLocalizations.of(context)!.error_connection);
      }
    }
  }
}
