import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/models/reminder.dart';
import 'package:wiqaya_app/models/user.dart';

class ReminderController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Reminder> reminders = [];
  Reminder? selectedReminder;
  int unseenCount = 0;
  bool isLoading = true;
  bool hasError = false;

  Future<void> getReminders() async {
    try {
      isLoading = true;
      hasError = false;
      notifyListeners();
      final response = await _apiClient.get('/notifications/${User.user!.id}');
      reminders = Reminder.notificationsFromJson(response.data);
    } catch (e) {
      reminders = [];
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

  Future<void> getUnseenCount() async {
    try {
      final response = await _apiClient.get('/notifications/${User.user!.id}/unseen_count');
      unseenCount = response.data['count'];
    } catch (e) {
      unseenCount = 0;
    } finally {
      notifyListeners();
    }
  }

  Future<void> markAllAsSeen() async {
    try {
      final response = await _apiClient.put('/notifications/${User.user!.id}/mark_all_as_seen');
      for (var reminder in reminders) {
        reminder.seen = true;
      }
      unseenCount = 0;
    } catch (e) {
      for (var reminder in reminders) {
        reminder.seen = false;
      }
    } finally {
      notifyListeners();
    }
  }
}

