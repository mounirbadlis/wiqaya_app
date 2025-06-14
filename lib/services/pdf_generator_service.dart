import 'dart:io';
import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:wiqaya_app/models/child.dart';
import 'package:wiqaya_app/models/historical_record.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wiqaya_app/models/user.dart';

class PdfGeneratorService {
  final BuildContext _buildContext;
  final List<HistoricalRecord> _records;
  final Child? child;
  PdfGeneratorService(this._buildContext, this._records, {this.child}) {
    generateAndSavePdf();
  }

  askPermission() async {
    final status = await Permission.storage.status;
    if (status.isGranted) {
      await Permission.storage.request();
    } else if (status.isDenied) {
      await Permission.storage.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
  Future<void> generateAndSavePdf() async {
  final hasPermission = await Permission.storage.isGranted;
  if (!hasPermission) await Permission.storage.request();

  final pdf = pw.Document();

  // Detect language
  final isArabic = Localizations.localeOf(_buildContext).languageCode == 'ar';

  // Load Arabic font if Arabic
  final arabicFont = pw.Font.ttf(await rootBundle.load('assets/fonts/cairo-regular.ttf'));

  final logo = await rootBundle.load('assets/logo/wiqaya_app_logo.png');

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        final content = pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(
                    width: 70.w,
                    height: 70.w,
                    pw.MemoryImage(
                      logo.buffer.asUint8List(),
                    ),
                  ),
                  pw.Text(
                    'Wiqaya', style: pw.TextStyle(font: arabicFont, fontSize: 20.sp),
                  ),
                ]
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Text(
                      '${AppLocalizations.of(_buildContext)!.full_name}: ${child?.familyName ?? User.user?.firstName ?? ''} ${child?.firstName ?? User.user?.firstName ?? ''}',
                      style: pw.TextStyle(font: arabicFont, fontSize: 15.sp),
                    ),
                    if(child != null)
                    pw.Text(
                      '${AppLocalizations.of(_buildContext)!.parent_name}: ${User.user?.firstName ?? ''} ${User.user?.familyName ?? ''}',
                      style: pw.TextStyle(font: arabicFont, fontSize: 15.sp),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(
                      '${AppLocalizations.of(_buildContext)!.age}: ${_calculateAge()}',
                      style: pw.TextStyle(font: arabicFont, fontSize: 15.sp),
                    ),
                    pw.Text(
                      '${AppLocalizations.of(_buildContext)!.blood_type}: ${child?.bloodType ?? User.user?.bloodType ?? ''}',
                      style: pw.TextStyle(font: arabicFont, fontSize: 15.sp),
                    ),
                  ],
                ),
              ],
            ),
            pw.Text(
              isArabic ? 'سجل التطعيمات' : 'Vaccination Records',
              style: pw.TextStyle(font: arabicFont, fontSize: 20.sp),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: [
                AppLocalizations.of(_buildContext)!.vaccine,
                AppLocalizations.of(_buildContext)!.date,
                AppLocalizations.of(_buildContext)!.center,
                AppLocalizations.of(_buildContext)!.provider_name,
              ],
              data: _records.map((r) => [
                r.vaccines,
                intl.DateFormat('yyyy-MM-dd').format(r.takedAt),
                r.centerName ?? 'N/A',
                r.providerName ?? 'N/A',
              ]).toList(),
              headerStyle: pw.TextStyle(
                font: arabicFont,
                fontSize: 12.sp,
              ),
              cellStyle: pw.TextStyle(
                font: arabicFont,
                fontSize: 10.sp,
              ),
              cellAlignment: isArabic
                  ? pw.Alignment.centerRight
                  : pw.Alignment.centerLeft,
            ),
          ],
        );

        return isArabic
            ? pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: content,
              )
            : content;
      },
    ),
  );

  final downloadsDir = Directory('/storage/emulated/0/Download');
  final filename = 'records_${child?.firstName ?? User.user?.firstName}_${Localizations.localeOf(_buildContext).languageCode}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  final file = File('${downloadsDir.path}/$filename');

  await file.writeAsBytes(await pdf.save());

  ScaffoldMessenger.of(_buildContext).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(_buildContext)!.pdf_saved)),
  );
  }

  String _calculateAge() {
    final now = DateTime.now();
    final birthDate = child?.birthDate ?? User.user?.birthDate;
    final age = now.difference(birthDate!).inDays ~/ 365;
    return '$age ${AppLocalizations.of(_buildContext)!.years_old}';
  }
}