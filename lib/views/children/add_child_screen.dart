// import 'package:flutter/material.dart';
// import 'package:wiqaya_app/views/main_screen.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class AddChildScreen extends StatefulWidget {
//   const AddChildScreen({super.key});

//   @override
//   State<AddChildScreen> createState() => _AddChildScreenState();
// }

// class _AddChildScreenState extends State<AddChildScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) {
//         if (!didPop) {
//           Navigator.pushNamed(context, '/main', arguments: MainScreen(selectedIndex: 2));
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).secondaryHeaderColor,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () {
//               Navigator.pushNamed(context, '/main', arguments: MainScreen(selectedIndex: 2));
//             },
//           ),
//           title: Text(AppLocalizations.of(context)!.add_child, style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
//         ),
//         body: const Placeholder(),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/children_controller.dart';
import 'package:wiqaya_app/models/child.dart';
import 'package:wiqaya_app/models/user.dart';
import 'package:wiqaya_app/views/main_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  
  DateTime? _selectedBirthDate;
  int? _selectedGender;
  String? _selectedBloodType;
  
  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _familyNameController.text = User.user?.familyName ?? '';
  }
  @override
  void dispose() {
    _firstNameController.dispose();
    _familyNameController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime.now().subtract(Duration(days: 365 * 18)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushNamed(context, '/main', arguments: MainScreen(selectedIndex: 2));
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/main', arguments: MainScreen(selectedIndex: 2));
            },
          ),
          title: Text(loc.add_child, style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
        ),
        body: Container(
          color: Theme.of(context).secondaryHeaderColor,
          padding: EdgeInsets.only(top: 10.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Name Field
                  _buildLabel(loc.first_name),
                  _buildTextField(
                    controller: _firstNameController,
                    hint: loc.first_name_hint,
                    validatorMsg: loc.first_name_required,
                  ),
                  
                  // Family Name Field
                  _buildLabel(loc.family_name),
                  _buildTextField(
                    controller: _familyNameController,
                    hint: loc.family_name_hint,
                    validatorMsg: loc.family_name_required,
                  ),
                  
                  // Birth Date Field
                  _buildLabel(loc.birth_date),
                  GestureDetector(
                    onTap: () => _selectBirthDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: loc.birth_date_hint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14.h,
                            horizontal: 12.w,
                          ),
                        ),
                        controller: TextEditingController(
                          text: _selectedBirthDate == null
                              ? ''
                              : DateFormat.yMd().format(_selectedBirthDate!),
                        ),
                        validator: (value) => 
                            _selectedBirthDate == null
                                ? loc.birth_date_required
                                : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  
                  // Gender Selection
                  _buildLabel(loc.gender),
                  DropdownButtonFormField<int>(
                    value: _selectedGender,
                    items: [
                      DropdownMenuItem(value: 1, child: Text(loc.male)),
                      DropdownMenuItem(value: 2, child: Text(loc.female)),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 12.w,
                      ),
                    ),
                    hint: Text(loc.gender_hint),
                    onChanged: (value) => setState(() => _selectedGender = value),
                    validator: (value) => value == null ? loc.gender_required : null,
                  ),
                  SizedBox(height: 20.h),
                  
                  // Blood Type Selection
                  _buildLabel(loc.blood_type),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedBloodType,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      hint: Text(loc.blood_type_hint),
                      validator: (value) => value == null ? loc.blood_type_required : null,
                      items: _bloodTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBloodType = newValue;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 40.h),
                  
                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _toNextScreen();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).secondaryHeaderColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        loc.next,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),)
    );
  }

  void _toNextScreen() {
    if (_formKey.currentState!.validate()) {
      final childrenController = Provider.of<ChildrenController>(context, listen: false);
      childrenController.newChild = Child(
        id: '',
        parentId: User.user?.id,
        firstName: _firstNameController.text,
        familyName: _familyNameController.text,
        birthDate: _selectedBirthDate!,
        gender: _selectedGender!,
        bloodType: _selectedBloodType!,
        type: 2,
      );
      Navigator.pushNamed(context, '/children/add/next');
    }
  }
  Widget _buildLabel(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            label,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String validatorMsg,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 14.h,
              horizontal: 12.w,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return validatorMsg;
            return null;
          },
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}