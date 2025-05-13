import 'package:flutter/material.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/models/historical_record.dart';
import 'package:wiqaya_app/models/user.dart';

class HistoricalRecordController extends ChangeNotifier {
  List<HistoricalRecord> historicalRecords = [];
  bool isLoading = false;
  bool hasError = false;

  Future<void> getHistoricalRecords(String id) async {
    try {
      isLoading = true;
      hasError = false;
      notifyListeners();
      final response = await ApiClient().get('/historical_records/$id');
      historicalRecords = HistoricalRecord.historicalRecordsFromJson(response.data);
    } catch (e) {
      print('getHistoricalRecords failed: $e');
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
