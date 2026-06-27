import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/localization_extension.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final cardColor = isDark ? AppColors.surfaceAltDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          context.loc.privacyPolicy,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سياسة الخصوصية وسرية المعلومات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.accent : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تاريخ التحديث: يونيو 2026',
              style: TextStyle(
                fontSize: 12,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildPolicySection(
              title: '1. مقدمة',
              content: 'تلتزم إدارة مدارس أنوار العُلى بحماية خصوصية بيانات أولياء الأمور والطلاب. توضح هذه السياسة كيفية جمع البيانات واستخدامها وحمايتها عند استخدام تطبيق ولي الأمر.',
              cardColor: cardColor,
              textColor: textColor,
              subTextColor: subTextColor,
              isDark: isDark,
            ),
            _buildPolicySection(
              title: '2. البيانات التي نقوم بجمعها',
              content: 'نقوم بجمع واستخدام البيانات اللازمة للمتابعة التعليمية فقط، وتشمل: المعلومات الشخصية لولي الأمر والطلاب (الاسم، الرقم الوطني، الصف والشعبة)، وسجل الحضور والغياب، الدرجات الأكاديمية، والواجبات المدرسية، بالإضافة للبيانات المالية والرسوم.',
              cardColor: cardColor,
              textColor: textColor,
              subTextColor: subTextColor,
              isDark: isDark,
            ),
            _buildPolicySection(
              title: '3. أذونات التطبيق المطلوبة',
              content: 'يطلب التطبيق بعض الأذونات الأساسية ليعمل بشكل سليم، مثل: أذونات التخزين المحلي (لحفظ وتنزيل كشوفات الدرجات أو جداول الاختبارات)، وإذن الإشعارات (لإرسال التنبيهات الفورية بخصوص الغياب، الواجبات الجديدة، أو الإعلانات الهامة من الإدارة).',
              cardColor: cardColor,
              textColor: textColor,
              subTextColor: subTextColor,
              isDark: isDark,
            ),
            _buildPolicySection(
              title: '4. مشاركة البيانات والجهات الخارجية',
              content: 'نحن لا نقوم ببيع أو مشاركة أو تأجير أي بيانات تخص ولي الأمر أو الطالب لأي جهات تجارية أو خارجية. جميع البيانات تُعالج بشكل آمن داخل الخوادم المخصصة للمدرسة وتُستخدم حصرياً للعملية التعليمية.',
              cardColor: cardColor,
              textColor: textColor,
              subTextColor: subTextColor,
              isDark: isDark,
            ),
            _buildPolicySection(
              title: '5. حماية وأمن المعلومات',
              content: 'نحن نطبق معايير أمنية صارمة وتقنيات تشفير متطورة لحماية البيانات من الوصول غير المصرح به أو التعديل أو الإفشاء. يرجى الحفاظ على سرية كلمة المرور الخاصة بك وعدم مشاركتها مع الآخرين.',
              cardColor: cardColor,
              textColor: textColor,
              subTextColor: subTextColor,
              isDark: isDark,
            ),
            _buildPolicySection(
              title: '6. التغييرات في سياسة الخصوصية',
              content: 'قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر لمواكبة التطورات التقنية والتنظيمية. سيتم إشعاركم بأي تغييرات جوهرية عبر التطبيق.',
              cardColor: cardColor,
              textColor: textColor,
              subTextColor: subTextColor,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'إذا كان لديكم أي استفسار حول سياسة الخصوصية، يرجى التواصل معنا عبر قسم الدعم.',
                style: TextStyle(
                  fontSize: 12,
                  color: subTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String content,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.5,
              color: subTextColor,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
