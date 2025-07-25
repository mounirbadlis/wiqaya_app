import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedBirthDate;
  int? _selectedGender;
  String? _selectedBloodType;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop,result) {
        if(!didPop) { Navigator.pushNamed(context, '/welcome');}
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  Image.asset(
                    'assets/logo/wiqaya_app_logo.png',
                    width: 130.w,
                    height: 130.h,
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      loc.register,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  SizedBox(height: 24.h),
      
                  // Email
                  _buildLabel(loc.email),
                  _buildTextField(
                    controller: _emailController,
                    hint: loc.email_hint,
                    validatorMsg: loc.email_required,
                    keyboardType: TextInputType.emailAddress,
                    validateEmail: true,
                  ),
      
                  // First Name
                  _buildLabel(loc.first_name),
                  _buildTextField(
                    controller: _firstNameController,
                    hint: loc.first_name_hint,
                    validatorMsg: loc.first_name_required,
                  ),
      
                  // Last Name
                  _buildLabel(loc.family_name),
                  _buildTextField(
                    controller: _lastNameController,
                    hint: loc.family_name_hint,
                    validatorMsg: loc.family_name_required,
                  ),
      
                  // Phone
                  _buildLabel(loc.phone),
                  _buildTextField(
                    controller: _phoneController,
                    hint: loc.phone_hint,
                    validatorMsg: loc.phone_required,
                    keyboardType: TextInputType.phone,
                    phoneValidation: true,
                  ),

                  // Blood Type
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
                  SizedBox(height: 20.h),

                  // Password
                  _buildLabel(loc.password),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: loc.password_hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 12.w,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? HugeIcons.strokeRoundedViewOffSlash
                              : HugeIcons.strokeRoundedView,
                        ),
                        onPressed:
                            () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? loc.password_required
                                : null,
                  ),
                  SizedBox(height: 20.h),
      
                  // Confirm Password
                  _buildLabel(loc.confirm_password),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: loc.confirm_password_hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 12.w,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? HugeIcons.strokeRoundedViewOffSlash
                              : HugeIcons.strokeRoundedView,
                        ),
                        onPressed:
                            () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.confirm_password_required;
                      } else if (value != _passwordController.text) {
                        return loc.passwords_do_not_match;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
      
                  // Birth Date
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
                          text:
                              _selectedBirthDate == null
                                  ? ''
                                  : DateFormat.yMd().format(_selectedBirthDate!),
                        ),
                        validator:
                            (value) =>
                                _selectedBirthDate == null
                                    ? loc.birth_date_required
                                    : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
      
                  // Gender
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
                    validator:
                        (value) => value == null ? loc.gender_required : null,
                  ),
                  SizedBox(height: 32.h),
      
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).secondaryHeaderColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1.sp,
                          )
                          : Text(
                        loc.register,
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          //padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
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
    bool validateEmail = false,
    bool phoneValidation = false,
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
            if (validateEmail &&
                !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return AppLocalizations.of(context)!.email_invalid;
            }
            if (phoneValidation &&
                !RegExp(r'^(05|06|07)[0-9]{8}$').hasMatch(value)) {
              return AppLocalizations.of(context)!.phone_invalid;
            }
            return null;
          },
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim();
      final familyName = _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final phone = _phoneController.text.trim();
      final gender = _selectedGender!;
      final birthDate = DateFormat('yyyy-MM-dd').format(_selectedBirthDate!);
      print('first name: $firstName');
      print('family name: $familyName');
      print('email: $email');
      print('password: $password');
      print('phone: $phone');
      print('gender: $gender');
      print('birth date: $birthDate');
      print('blood type: $_selectedBloodType');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        setState(() {
          _isLoading = true;
        });
        await Provider.of<AuthController>(context, listen: false).register(
          email: email,
          password: password,
          firstName: firstName,
          familyName: familyName,
          birthDate: birthDate,
          phone: phone,
          gender: gender,
          bloodType: _selectedBloodType!,
          context: context,
        );

        if (mounted) {
          Navigator.of(context).pop(); // close loader
          _showSnackBar(AppLocalizations.of(context)!.registration_success);
          Navigator.pushReplacementNamed(context, '/main');
          // Navigate to another screen if needed
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // close loader
          _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
