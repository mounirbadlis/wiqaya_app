// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:wiqaya_app/models/user.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) {
//         if (!didPop) {
//           Navigator.pop(context);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Theme.of(context).primaryColor,
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).secondaryHeaderColor,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           title: Text(AppLocalizations.of(context)!.profile, style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
//         ),
//         body: Container(
//           color: Theme.of(context).secondaryHeaderColor,
//           padding: EdgeInsets.only(top: 10.w),
//           child: Container(
//             padding: EdgeInsets.all(10.w),
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Column(
//                       children: [
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/auth_controller.dart';
import 'package:wiqaya_app/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      setState(() {
        _user = authController.user;
        _firstNameController.text = _user?.firstName ?? '';
        _familyNameController.text = _user?.familyName ?? '';
        _emailController.text = _user?.email ?? '';
        _phoneController.text = _user?.phone ?? '';
      });
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.error_connection);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _familyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _currentPasswordController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    final isPasswordFieldFilled = _currentPasswordController.text.isNotEmpty ||
        _passwordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty;

    if (isPasswordFieldFilled) {
      if (_currentPasswordController.text.isEmpty) {
        _showSnackBar(AppLocalizations.of(context)!.current_password_required);
        return false;
      }
      if (_passwordController.text.isEmpty) {
        _showSnackBar(AppLocalizations.of(context)!.password_required);
        return false;
      }
      if (_confirmPasswordController.text.isEmpty) {
        _showSnackBar(AppLocalizations.of(context)!.confirm_password_required);
        return false;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showSnackBar(AppLocalizations.of(context)!.passwords_do_not_match);
        return false;
      }
    }

    return true;
  }

  void _submit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      await authController.editProfile(
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        familyName: _familyNameController.text.trim(),
        phone: _phoneController.text.trim(),
        currentPassword: _currentPasswordController.text,
        password: _passwordController.text,
        context: context,
      );

      if (mounted) {
        _showSnackBar(AppLocalizations.of(context)!.profile_updated);
        setState(() {
          _isEditing = false;
          _currentPasswordController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(loc.profile, style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
        ),
        body: _user == null
            ? const Center(child: CircularProgressIndicator())
            : Container(
              color: Theme.of(context).secondaryHeaderColor,
              padding: EdgeInsets.only(top: 10.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          Text(loc.personal_info, style: Theme.of(context).textTheme.headlineSmall),
                          SizedBox(height: 20.h),
                          // First Name
                          _buildLabel(loc.first_name),
                          _buildTextField(
                            controller: _firstNameController,
                            hint: loc.first_name_hint,
                            validatorMsg: loc.first_name_required,
                            enabled: _isEditing,
                          ),
                          // Family Name
                          _buildLabel(loc.family_name),
                          _buildTextField(
                            controller: _familyNameController,
                            hint: loc.family_name_hint,
                            validatorMsg: loc.family_name_required,
                            enabled: _isEditing,
                          ),
                          // Email
                          _buildLabel(loc.email),
                          _buildTextField(
                            controller: _emailController,
                            hint: loc.email_hint,
                            validatorMsg: loc.email_required,
                            keyboardType: TextInputType.emailAddress,
                            validateEmail: true,
                            enabled: _isEditing,
                          ),
                          // Phone
                          _buildLabel(loc.phone),
                          _buildTextField(
                            controller: _phoneController,
                            hint: loc.phone_hint,
                            validatorMsg: loc.phone_required,
                            keyboardType: TextInputType.phone,
                            phoneValidation: true,
                            enabled: _isEditing,
                          ),
                          if (_isEditing) ...[
                            SizedBox(height: 20.h),
                            Divider(color: Theme.of(context).colorScheme.outline),
                            SizedBox(height: 20.h),
                            Text(loc.change_password_optional, style: Theme.of(context).textTheme.headlineSmall),
                            SizedBox(height: 20.h),
                            // Current Password
                            _buildLabel(loc.current_password),
                            _buildPasswordField(
                              controller: _currentPasswordController,
                              hint: loc.current_password_hint,
                              validatorMsg: loc.current_password_required,
                            ),
                            // New Password
                            _buildLabel(loc.password),
                            _buildPasswordField(
                              controller: _passwordController,
                              hint: loc.password_hint,
                              validatorMsg: loc.password_required,
                            ),
                            // Confirm Password
                            _buildLabel(loc.confirm_password),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              hint: loc.confirm_password_hint,
                              validatorMsg: loc.confirm_password_required,
                            ),
                          ],
                          SizedBox(height: 32.h),
                          // Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!_isEditing)
                                ElevatedButton(
                                  onPressed: _toggleEdit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).secondaryHeaderColor,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 12.h),
                                  ),
                                  child: Text(loc.edit_profile, style: TextStyle(fontSize: 16.sp, color: Colors.white)),
                                ),
                              if (_isEditing) ...[
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 12.h),
                                  ),
                                  child: _isLoading
                                      ? CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 1.sp,
                                        )
                                      : Text(loc.save_changes, style: TextStyle(fontSize: 16.sp, color: Colors.white)),
                                ),
                                SizedBox(width: 10.w),
                                OutlinedButton(
                                  onPressed: _toggleEdit,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Theme.of(context).colorScheme.outline),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 12.h),
                                  ),
                                  child: Text(loc.cancel, style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface)),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
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
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required String validatorMsg, TextInputType keyboardType = TextInputType.text, bool validateEmail = false, bool phoneValidation = false, bool enabled = true,}) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
            filled: !enabled,
            fillColor: enabled ? null : Theme.of(context).colorScheme.surface.withOpacity(0.1),
            contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return validatorMsg;
            if (validateEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return AppLocalizations.of(context)!.email_invalid;
            }
            if (phoneValidation && !RegExp(r'^(05|06|07)[0-9]{8}$').hasMatch(value)) {
              return AppLocalizations.of(context)!.phone_invalid;
            }
            return null;
          },
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildPasswordField({required TextEditingController controller, required String hint, required String validatorMsg,}) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? HugeIcons.strokeRoundedViewOffSlash : HugeIcons.strokeRoundedView,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}