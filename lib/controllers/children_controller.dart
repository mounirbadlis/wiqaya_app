import 'package:flutter/material.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/models/child.dart';

import '../models/user.dart';

class ChildrenController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Child> children = [];
  Child? selectedChild;
  Child? newChild;
  bool isLoading = true;
  bool hasError = false;

  Future<void> getChildren() async {
    try {
      isLoading = true;
      hasError = false;
      notifyListeners();
      final response = await _apiClient.get('/children', data: {'parent_id': User.user?.id});
      children = Child.childrenFromJson(response.data);
    } catch (e) {
      print('getChildren failed: $e');
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addChild() async {
    try {
      isLoading = true;
      hasError = false;
      notifyListeners();
      final response = await _apiClient.post('/children', data: {'parent_id': User.user?.id, 'first_name': newChild?.firstName, 'family_name': newChild?.familyName, 'gender': newChild?.gender, 'birth_date': newChild?.birthDate, 'blood_type': newChild?.bloodType});
      newChild = Child.fromJson(response.data);
    } catch (e) {
      print('addChild failed: $e');
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
