import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wiqaya_app/api/api_client.dart';
import 'package:wiqaya_app/models/child.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/user.dart';
import 'package:intl/intl.dart' as intl;

class ChildrenController extends ChangeNotifier {
  final ApiClient apiClient = ApiClient();
  List<Child> children = [];
  Child? selectedChild;
  Child? newChild;
  bool isLoading = true;
  bool hasError = false;

  // Future<void> getChildren() async {
  //   try {
  //     isLoading = true;
  //     hasError = false;
  //     notifyListeners();
  //     final response = await apiClient.get('/children/${User.user?.id}');
  //     children = Child.childrenFromJson(response.data);
  //   } on DioException catch (e) {
  //     print('getChildren failed: ${e.response?.data}');
  //     hasError = true;
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }
  Future<void> getChildren() async {
  try {
    isLoading = true;
    hasError = false;
    notifyListeners();

    final response = await apiClient.get('/children/${User.user?.id}');
    
    print('getChildren status: ${response.statusCode}');
    print('getChildren data: ${response.data}');

    if (response.statusCode == 200) {
      children = Child.childrenFromJson(response.data);
    } else {
      hasError = true;
      print('Unexpected status code: ${response.statusCode}');
    }

  } on DioException catch (e) {
    print('DioException during getChildren: $e');
    print('Status code: ${e.response?.statusCode}');
    print('Error response: ${e.response?.data}');
    
    hasError = true;

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      print('Connection error (no internet?)');
    } else if (e.response?.statusCode == 500) {
      print('Server error');
    } else {
      print('Other Dio error');
    }

  } catch (e) {
    hasError = true;
    print('Unexpected error during getChildren: $e');
  } finally {
    isLoading = false;
    notifyListeners();
  }
}


  Future<void> addChild(List<Map<String, dynamic>> takenVaccines, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      final response = await apiClient.post('/children', data: {'parent_id': User.user?.id, 'first_name': newChild?.firstName, 'family_name': newChild?.familyName, 'birth_date': intl.DateFormat('yyyy-MM-dd').format(newChild!.birthDate), 'gender': newChild?.gender, 'blood_type': newChild?.bloodType, 'taken_vaccines': takenVaccines});
      newChild = Child.fromJson(response.data);
    } catch (e) {
      print('Error from server: ${e}');
      if (e is DioException) {
        final status = e.response?.statusCode;
        if (status == 401) {
          throw Exception(AppLocalizations.of(context)!.error_invalid_password);
        } else if (status == 500) {
          throw Exception(AppLocalizations.of(context)!.error_server);
        } else {
          throw Exception(
            AppLocalizations.of(context)!.error_connection,
          );
        }
      } else {
        throw Exception(e.toString());
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
