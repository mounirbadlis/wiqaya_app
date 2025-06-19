// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:provider/provider.dart';
// import 'package:wiqaya_app/controllers/appointment_controller.dart';
// import 'package:wiqaya_app/models/appointment.dart';
// import 'package:wiqaya_app/models/user.dart';
// import 'package:wiqaya_app/providers/locale_provider.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<AppointmentController>(context, listen: false).getTodayAppointments(User.user!.id);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       body: Container(
//         padding: EdgeInsets.all(5.w),
//         decoration: BoxDecoration(
//           color: Theme.of(context).primaryColor,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//            Card(
//             color: Theme.of(context).secondaryHeaderColor,
//             child: Container(
//               width: double.infinity,
//               height: 200.h,
//               padding: EdgeInsets.all(10.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('${AppLocalizations.of(context)!.hi}, ${User.user!.firstName}', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
//                   Spacer(),
//                   InkWell(
//                     onTap: () {
                      
//                     },
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(AppLocalizations.of(context)!.profile, style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white, fontSize: 20.sp)),
//                         Icon(Provider.of<LocaleProvider>(context).locale.languageCode == 'en' ? Icons.arrow_back_ios : Icons.arrow_forward_ios, size: 20.w, color: Colors.white,),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//            ),
//            Padding(
//              padding: EdgeInsets.all(5.w),
//              child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 10.h,),
//                 Text(AppLocalizations.of(context)!.quick_actions, style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black)),
//                 SizedBox(height: 5.h,),
//                 Row(
//                  children: [
//                   _buildQuickActionWidget(context, HugeIcons.strokeRoundedVaccine, AppLocalizations.of(context)!.vaccines, Colors.cyan, () { Navigator.pushNamed(context, '/vaccines');}),
//                   _buildQuickActionWidget(context, HugeIcons.strokeRoundedAdd01, AppLocalizations.of(context)!.add_child, Colors.cyan, () { Navigator.pushNamed(context, '/children/add');}),
//                   _buildQuickActionWidget(context, HugeIcons.strokeRoundedAiScheduling, AppLocalizations.of(context)!.book_appointment, Colors.cyan, () { Navigator.pushNamed(context, '/appointments/book');}),
//                  ],
//                ),
//                SizedBox(height: 10.h,),
//                Text(AppLocalizations.of(context)!.today_appointments, style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black)),
//                SizedBox(height: 5.h,),
//                if (Provider.of<AppointmentController>(context).isTodayAppointmentsLoading)
//                  Center(child: CircularProgressIndicator(),)
//                else if (Provider.of<AppointmentController>(context).appointments.isEmpty)
//                  Center(child: Text(AppLocalizations.of(context)!.no_data),)
//                else
//                  ListView.builder(
//                    shrinkWrap: true,
//                    itemCount: Provider.of<AppointmentController>(context).appointments.length,
//                    itemBuilder: (context, index) {
//                      return _buildAppointmentCard(context, Provider.of<AppointmentController>(context).appointments[index]);
//                    },
//                  ),
//               ],
//            ),
//            ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickActionWidget (BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 5.w),
//         child: Column(
//           children: [
//             Container(
//               width: 80.w,
//               height: 80.w,
//               padding: EdgeInsets.all(10.w),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: color,
//               ),
//               child: Icon(icon, color: Colors.white, size: 45.w,),
//             ),
//             SizedBox(height: 5.h,),
//             Text(title, style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 5.h),
//       child: Card(
//         child: Container(
//           padding: EdgeInsets.all(10.w),
//           child: Column(
//             children: [
//               Text(appointment.vaccine?.name ?? '', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black)),
//               SizedBox(height: 5.h,),
//               Text(appointment.center?.name ?? '', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black)),
//               SizedBox(height: 5.h,),
//               Text(intl.DateFormat('yyyy-MM-dd').format(appointment.schedule?.date ?? DateTime.now()), style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black)),
//             ],
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
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/appointment_controller.dart';
import 'package:wiqaya_app/models/appointment.dart';
import 'package:wiqaya_app/models/user.dart';
import 'package:wiqaya_app/providers/locale_provider.dart';
import 'package:wiqaya_app/widgets/shared/ask_questions_manual_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentController>(context, listen: false).getTodayAppointments(User.user!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card with improved design
              Container(
                margin: EdgeInsets.only(bottom: 20.h),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  color: Theme.of(context).secondaryHeaderColor,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).secondaryHeaderColor,
                          Theme.of(context).secondaryHeaderColor.withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24.w,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${AppLocalizations.of(context)!.hi}!',
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  Text(
                                    '${User.user!.firstName}',
                                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        InkWell(
                          onTap: () {
                            // Navigate to profile
                            Navigator.pushNamed(context, '/profile');
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.profile,
                                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Provider.of<LocaleProvider>(context).locale.languageCode == 'en' 
                                    ? Icons.arrow_forward_ios 
                                    : Icons.arrow_back_ios,
                                  size: 16.w,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Quick Actions Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          AppLocalizations.of(context)!.quick_actions,
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickActionWidget(
                          context,
                          HugeIcons.strokeRoundedVaccine,
                          AppLocalizations.of(context)!.vaccines,
                          Colors.teal,
                          () { Navigator.pushNamed(context, '/vaccines'); }
                        ),
                        _buildQuickActionWidget(
                          context,
                          HugeIcons.strokeRoundedAdd01,
                          AppLocalizations.of(context)!.add_child,
                          Colors.orange,
                          () { Navigator.pushNamed(context, '/children/add'); }
                        ),
                        _buildQuickActionWidget(
                          context,
                          HugeIcons.strokeRoundedAiScheduling,
                          AppLocalizations.of(context)!.book_appointment,
                          Colors.blue,
                          () { AskQuestionsManualDialog.show(context); }
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    
                    // Today's Appointments Section
                    Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          AppLocalizations.of(context)!.today_appointments,
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    
                    if (Provider.of<AppointmentController>(context).isTodayAppointmentsLoading)
                      Container(
                        height: 120.h,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                      )
                    else if (Provider.of<AppointmentController>(context).appointments.isEmpty)
                      Container(
                        height: 120.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 40.w,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                AppLocalizations.of(context)!.no_data,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: Provider.of<AppointmentController>(context).appointments.length,
                        itemBuilder: (context, index) {
                          return _buildAppointmentCard(
                            context,
                            Provider.of<AppointmentController>(context).appointments[index]
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionWidget(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            children: [
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32.w,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: Theme.of(context).secondaryHeaderColor,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.vaccine?.name ?? '',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14.w,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            appointment.center?.name ?? '',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14.w,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          intl.DateFormat('MMM dd, yyyy').format(
                            appointment.schedule?.date ?? DateTime.now()
                          ),
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}