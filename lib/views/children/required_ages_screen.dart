import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/children_controller.dart';
import 'package:wiqaya_app/models/child.dart';
import 'package:wiqaya_app/views/main_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RequiredAgesScreen extends StatefulWidget {
  const RequiredAgesScreen({super.key});

  @override
  State<RequiredAgesScreen> createState() => _RequiredAgesScreenState();
}

class _RequiredAgesScreenState extends State<RequiredAgesScreen> {
  late AppLocalizations loc;
  final Map<String, bool> _vaccineStatus = {};
  late final List<Map<String, dynamic>> _vaccines;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeVaccines();
  }

  void _initializeVaccines() {
    // Get child from controller
    final childrenController = Provider.of<ChildrenController>(context, listen: false);
    final Child child = childrenController.newChild!;
    
    // Calculate age in months
    final DateTime now = DateTime.now();
    final DateTime birthDate = child.birthDate;
    final int ageInMonths = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    
    // Define vaccines with their required ages
    _vaccines = [
      {'name': 'BCG', 'required_age': 0, 'vaccine': 'BCG', 'description': 'Tuberculosis vaccine'},
      {'name': 'DTC-HIB-HBV 1', 'required_age': 2, 'vaccine': 'DTC-HIB-HBV', 'description': 'Diphtheria, Tetanus, Pertussis, Hib, Hepatitis B (1st dose)'},
      {'name': 'VPO 1', 'required_age': 2, 'vaccine': 'VPO', 'description': 'Oral Polio Vaccine (1st dose)'},
      {'name': 'DTC-HIB-HBV 2', 'required_age': 4, 'vaccine': 'DTC-HIB-HBV', 'description': 'Diphtheria, Tetanus, Pertussis, Hib, Hepatitis B (2nd dose)'},
      {'name': 'VPO 2', 'required_age': 4, 'vaccine': 'VPO', 'description': 'Oral Polio Vaccine (2nd dose)'},
      {'name': 'ROR 1', 'required_age': 11, 'vaccine': 'ROR', 'description': 'Measles, Mumps, Rubella (1st dose)'},
      {'name': 'DTC-HIB-HBV 3', 'required_age': 12, 'vaccine': 'DTC-HIB-HBV', 'description': 'Diphtheria, Tetanus, Pertussis, Hib, Hepatitis B (3rd dose)'},
      {'name': 'VPO 3', 'required_age': 12, 'vaccine': 'VPO', 'description': 'Oral Polio Vaccine (3rd dose)'},
      {'name': 'ROR 2', 'required_age': 12, 'vaccine': 'ROR', 'description': 'Measles, Mumps, Rubella (2nd dose)'},
    ];
    
    // Filter vaccines based on child's age
    _vaccines.removeWhere((vaccine) => vaccine['required_age'] > ageInMonths);
    
    // Initialize all vaccines as unchecked
    for (var vaccine in _vaccines) {
      _vaccineStatus[vaccine['name']] = false;
    }
    print(_vaccineStatus);
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context)!;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(loc.record ?? 'Vaccine History', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
        ),
        body: Container(
          color: Theme.of(context).secondaryHeaderColor,
          padding: EdgeInsets.only(top: 10.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.select_vaccines,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 20.h),
                
                Expanded(
                  child: _vaccines.isEmpty
                      ? Center(
                          child: Text(
                            loc.no_vaccines_for_age,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _vaccines.length,
                          itemBuilder: (context, index) {
                            final vaccine = _vaccines[index];
                            return _buildVaccineCheckbox(vaccine);
                          },
                        ),
                ),
                
                SizedBox(height: 20.h),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveVaccineData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).secondaryHeaderColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: _isLoading ? CircularProgressIndicator(color: Colors.white, strokeWidth: 1.sp,) : Text(loc.add, style: TextStyle(fontSize: 16.sp,color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVaccineCheckbox(Map<String, dynamic> vaccine) {
    String _setVaccineAge(Map<String, dynamic> vaccine) {
      if(vaccine['required_age'] == 0){
        return loc.birth;
      }else{
        return '${vaccine['required_age']} ${loc.months}';
      }
    }
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: CheckboxListTile(
        title: Text(
          vaccine['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        subtitle: Text(_setVaccineAge(vaccine)),
        value: _vaccineStatus[vaccine['name']] ?? false,
        onChanged: (bool? value) {
          setState(() {
            _vaccineStatus[vaccine['name']] = value ?? false;
            print(_vaccineStatus);
          });
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        activeColor: Theme.of(context).secondaryHeaderColor,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
  Future<void> _saveVaccineData() async {
  final childrenController = Provider.of<ChildrenController>(context, listen: false);

  final List<Map<String, dynamic>> selectedVaccines = [];

  _vaccineStatus.forEach((doseName, isChecked) {
    if (isChecked) {
      final matchedVaccine = _vaccines.firstWhere(
        (v) => v['name'] == doseName,
        orElse: () => {},
      );

      if (matchedVaccine.isNotEmpty) {
        selectedVaccines.add({
          'name': matchedVaccine['vaccine'],
          'value': true,
        });
      }
    }
  });
  try {
    setState(() => _isLoading = true);
    await childrenController.addChild(selectedVaccines, context);
    Navigator.pop(context);
  } catch (e) {
    _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

void _showSnackBar(String message) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
}