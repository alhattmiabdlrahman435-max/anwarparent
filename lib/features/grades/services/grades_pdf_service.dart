import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' as intl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/models/grade.dart';
import '../../../../core/models/student.dart';

class GradesPdfService {
  /// Generates the PDF document for the student's report card.
  static Future<Uint8List> generateReportCardPdf({
    required Student student,
    required List<SubjectGrade> subjects,
    required int selectedTerm,
  }) async {
    final pdf = pw.Document();

    // 1. Load School Logo if available
    Uint8List? logoBytes;
    try {
      final byteData = await rootBundle.load('assets/icons/app_icon.jpeg');
      logoBytes = byteData.buffer.asUint8List();
    } catch (_) {
      // Graceful fallback for tests or if asset is missing
    }

    // 2. Load Arabic Font - Cairo via GoogleFonts (with offline cache)
    pw.Font fontRegular;
    pw.Font fontBold;

    try {
      fontRegular = await PdfGoogleFonts.cairoRegular();
      fontBold = await PdfGoogleFonts.cairoBold();
    } catch (_) {
      try {
        fontRegular = await PdfGoogleFonts.amiriRegular();
        fontBold = await PdfGoogleFonts.amiriBold();
      } catch (_) {
        fontRegular = pw.Font.helvetica();
        fontBold = pw.Font.helveticaBold();
      }
    }

    // Calculations
    double totalObtained = 0.0;
    for (final s in subjects) {
      final termData = selectedTerm == 1 ? s.term1 : s.term2;
      totalObtained += termData.total;
    }

    final double maxTotal = subjects.length * 50.0;
    final double overallPercentage = maxTotal > 0 ? (totalObtained / maxTotal) * 100 : 0.0;

    final summaryTitle = selectedTerm == 1
        ? 'المجموع العام لمنتصف العام'
        : 'المجموع العام لنهاية العام';

    final reportTitle = selectedTerm == 1
        ? 'إشعار نتيجة منتصف العام - الفصل الدراسي الأول'
        : 'إشعار نتيجة نهاية العام - الفصل الدراسي الثاني';

    final currentDate = intl.DateFormat('yyyy/MM/dd').format(DateTime.now());

    const primaryColor = PdfColor.fromInt(0xFF062A5A);
    const secondaryColor = PdfColor.fromInt(0xFF0B4386);
    const borderColor = PdfColor.fromInt(0xFFCBD5E1);
    const headerBgColor = PdfColor.fromInt(0xFFF1F5F9);
    const rowAltColor = PdfColor.fromInt(0xFFF8FAFC);

    final logoImage = logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // 1. Top Header Box with School Logo
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF8FAFC),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(14)),
                    border: pw.Border.all(color: primaryColor, width: 1.5),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Right side: Logo
                      if (logoImage != null)
                        pw.Container(
                          width: 52,
                          height: 52,
                          decoration: pw.BoxDecoration(
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                            border: pw.Border.all(color: borderColor, width: 0.8),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 10,
                            verticalRadius: 10,
                            child: pw.Image(
                              logoImage,
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        pw.SizedBox(width: 52, height: 52),

                      // Center: School Name and Report Subtitle
                      pw.Expanded(
                        child: pw.Column(
                          mainAxisSize: pw.MainAxisSize.min,
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              'رياض ومدارس أنوار العلى الدولية النموذجية',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 17,
                                color: primaryColor,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: const pw.BoxDecoration(
                                color: primaryColor,
                                borderRadius: pw.BorderRadius.all(pw.Radius.circular(20)),
                              ),
                              child: pw.Text(
                                reportTitle,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 11,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Left side: Matching sized spacer to keep title perfectly centered
                      pw.SizedBox(width: 52, height: 52),
                    ],
                  ),
                ),
                pw.SizedBox(height: 14),

                // 2. Student Info Card
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: pw.BoxDecoration(
                    color: headerBgColor,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                    border: pw.Border.all(color: borderColor, width: 1),
                  ),
                  child: pw.Row(
                    children: [
                      // Right: Student Name
                      pw.Expanded(
                        flex: 4,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'اسم الطالب:',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              student.name,
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 12,
                                color: PdfColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(width: 1, height: 30, color: borderColor),
                      pw.SizedBox(width: 12),
                      // Middle: Grade / Stage
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'الصف / المرحلة:',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              student.grade.isNotEmpty ? student.grade : 'غير محدد',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 11,
                                color: PdfColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(width: 1, height: 30, color: borderColor),
                      pw.SizedBox(width: 12),
                      // Left: Print Date
                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'تاريخ الطباعة:',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              currentDate,
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 10,
                                color: PdfColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),

                // 3. Grades Table (Arranged so Rightmost column is 'المادة' and Leftmost is 'التقدير')
                pw.Table(
                  border: pw.TableBorder.all(color: borderColor, width: 0.8),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2.0), // التقدير (أقصى اليسار)
                    1: pw.FlexColumnWidth(2.0), // المجموع (50)
                    2: pw.FlexColumnWidth(2.0), // النهائي (30)
                    3: pw.FlexColumnWidth(2.0), // المحصلة (20)
                    4: pw.FlexColumnWidth(3.8), // المادة (أقصى اليمين)
                  },
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: primaryColor,
                      ),
                      children: [
                        _buildTableHeaderCell('التقدير', fontBold),
                        _buildTableHeaderCell('المجموع (50)', fontBold),
                        _buildTableHeaderCell('النهائي (30)', fontBold),
                        _buildTableHeaderCell('المحصلة (20)', fontBold),
                        _buildTableHeaderCell(
                          'المادة',
                          fontBold,
                          align: pw.TextAlign.right,
                          alignment: pw.Alignment.centerRight,
                        ),
                      ],
                    ),

                    // Rows
                    ...subjects.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final sub = entry.value;
                      final termData = selectedTerm == 1 ? sub.term1 : sub.term2;
                      final isEven = idx % 2 == 0;
                      final appreciation = _getAppreciationText(termData.total);
                      final appreciationColor = _getAppreciationPdfColor(termData.total);

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: isEven ? rowAltColor : PdfColors.white,
                        ),
                        children: [
                          _buildTableCell(
                            appreciation,
                            fontBold,
                            color: appreciationColor,
                          ),
                          _buildTableCell(
                            termData.total.toStringAsFixed(1).replaceAll('.0', ''),
                            fontBold,
                            color: primaryColor,
                          ),
                          _buildTableCell(
                            termData.termExam.toStringAsFixed(1).replaceAll('.0', ''),
                            fontRegular,
                          ),
                          _buildTableCell(
                            termData.outcome.toStringAsFixed(1).replaceAll('.0', ''),
                            fontRegular,
                          ),
                          _buildTableCell(
                            sub.subjectName,
                            fontBold,
                            align: pw.TextAlign.right,
                            alignment: pw.Alignment.centerRight,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 14),

                // 4. Total Summary Box
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: const pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            summaryTitle,
                            style: const pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            '${totalObtained.toStringAsFixed(1).replaceAll('.0', '')} / ${maxTotal.toStringAsFixed(0)}',
                            textDirection: pw.TextDirection.ltr,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 17,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: pw.BoxDecoration(
                          color: secondaryColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                          border: pw.Border.all(color: PdfColors.white, width: 0.8),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'النسبة المئوية',
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              '${overallPercentage.toStringAsFixed(1)}%',
                              textDirection: pw.TextDirection.ltr,
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 16,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // 5. Signatures
                pw.Container(
                  padding: const pw.EdgeInsets.only(top: 10),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildSignatureColumn('مربي الفصل', fontBold),
                      _buildSignatureColumn('المرشد الطلابي', fontBold),
                      _buildSignatureColumn('مدير المدرسة / الختم', fontBold),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                // 6. Watermark Footer
                pw.Divider(color: borderColor, thickness: 0.5),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    'تم إصدار هذا الإشعار رسمياً من تطبيق أولياء الأمور - مدارس أنوار العلى',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTableHeaderCell(
    String text,
    pw.Font fontBold, {
    pw.TextAlign align = pw.TextAlign.center,
    pw.Alignment alignment = pw.Alignment.center,
  }) {
    return pw.Container(
      alignment: alignment,
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: fontBold,
          fontSize: 10,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    pw.TextAlign align = pw.TextAlign.center,
    pw.Alignment alignment = pw.Alignment.center,
    PdfColor color = PdfColors.black,
  }) {
    return pw.Container(
      alignment: alignment,
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }

  static pw.Widget _buildSignatureColumn(String title, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 10,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          '...........................',
          style: const pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey500,
          ),
        ),
      ],
    );
  }

  static String _getAppreciationText(double totalOutOf50) {
    final double percentage = totalOutOf50 * 2;
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 80) return 'جيد جداً';
    if (percentage >= 65) return 'جيد';
    if (percentage >= 50) return 'مقبول';
    return 'ضعيف';
  }

  static PdfColor _getAppreciationPdfColor(double totalOutOf50) {
    final double percentage = totalOutOf50 * 2;
    if (percentage >= 90) return const PdfColor.fromInt(0xFF059669);
    if (percentage >= 80) return const PdfColor.fromInt(0xFF0284C7);
    if (percentage >= 65) return const PdfColor.fromInt(0xFFD97706);
    if (percentage >= 50) return const PdfColor.fromInt(0xFFEA580C);
    return const PdfColor.fromInt(0xFFDC2626);
  }

  /// Opens the PDF in the system previewer / printer, allowing instant downloading and sharing.
  static Future<void> printOrSharePdf({
    required Student student,
    required List<SubjectGrade> subjects,
    required int selectedTerm,
  }) async {
    final pdfBytes = await generateReportCardPdf(
      student: student,
      subjects: subjects,
      selectedTerm: selectedTerm,
    );

    final termSuffix = selectedTerm == 1 ? 'الفصل_الأول' : 'الفصل_الثاني';
    final fileName = 'اشعار_${termSuffix}_${student.name.replaceAll(' ', '_')}.pdf';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: fileName,
    );
  }

  /// Directly opens the system share sheet to share or save the file.
  static Future<void> sharePdfFile({
    required Student student,
    required List<SubjectGrade> subjects,
    required int selectedTerm,
  }) async {
    final pdfBytes = await generateReportCardPdf(
      student: student,
      subjects: subjects,
      selectedTerm: selectedTerm,
    );

    final termSuffix = selectedTerm == 1 ? 'الفصل_الأول' : 'الفصل_الثاني';
    final fileName = 'اشعار_${termSuffix}_${student.name.replaceAll(' ', '_')}.pdf';

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: fileName,
    );
  }
}
