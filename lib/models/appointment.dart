
import 'package:wiqaya_app/models/vaccination_center.dart';
import 'package:wiqaya_app/models/schedule.dart';
import 'package:wiqaya_app/models/vaccine.dart';

class Appointment {
  final String id;
  final String individualId;
  final String scheduleVaccinesId;
  int status;
  String? firstName;
  String? familyName;
  Schedule? schedule;
  VaccinationCenter? center;
  Vaccine? vaccine;

  Appointment({
    required this.id,
    required this.individualId,
    required this.scheduleVaccinesId,
    this.status = 1,
    this.firstName,
    this.familyName,
    this.schedule,
    this.center,
    this.vaccine,
  });

factory Appointment.fromJson(Map<String, dynamic> json) {
  final individuals = json['individuals'];
  final scheduleVaccines = json['schedule_vaccines'];
  final schedules = scheduleVaccines?['schedules'];
  final centers = schedules?['centers'];
  final vaccines = scheduleVaccines?['vaccines'];

  return Appointment(
    id: json['id'],
    individualId: json['individual_id'],
    scheduleVaccinesId: json['schedule_vaccines_id'],
    status: json['status'] ?? 1,
    firstName: individuals != null ? individuals['first_name'] : null,
    familyName: individuals != null ? individuals['family_name'] : null,
    schedule: schedules != null ? Schedule.fromJson(schedules) : null,
    center: centers != null ? VaccinationCenter.fromJson(centers) : null,
    vaccine: vaccines != null ? Vaccine.fromJson(vaccines) : null,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'individual_id': individualId,
      'schedule_vaccines_id': scheduleVaccinesId,
      'status': status,
      'firstName': firstName,
      'familyName': familyName,
      'schedule': schedule?.toJson(),
      'center': center?.toJson(),
      'vaccine': vaccine?.toJson(),
    };
  }

  static List<Appointment> appointmentsFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Appointment.fromJson(json)).toList();
  }
}
