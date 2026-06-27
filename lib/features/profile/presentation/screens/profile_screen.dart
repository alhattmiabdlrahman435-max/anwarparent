import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/extensions/localization_extension.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Parent info states
  String _parentName = 'محمد عبدالله الموقري';
  final String _nationalId = '1029384756';
  String _phone = '+967 777 777 777';
  String _address = 'صنعاء - شارع الستين';
  
  // Real picked image path
  String? _pickedImagePath;
  
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _parentName);
    _phoneController = TextEditingController(text: _phone);
    _addressController = TextEditingController(text: _address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceAltDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تحديث صورة الملف الشخصي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  fontFamily: 'GoogleSans',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : AppColors.border,
                        ),
                      ),
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        color: isDark ? AppColors.accent : AppColors.primary,
                      ),
                      label: Text(
                        'التقاط صورة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          fontFamily: 'GoogleSans',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : AppColors.border,
                        ),
                      ),
                      icon: Icon(
                        Icons.photo_library_rounded,
                        color: isDark ? AppColors.accent : AppColors.primary,
                      ),
                      label: Text(
                        'من المعرض',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          fontFamily: 'GoogleSans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _pickedImagePath = image.path;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم تحديث صورة الملف الشخصي بنجاح'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في الحصول على الصورة: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _saveDetails() {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _parentName = _nameController.text;
      _phone = _phoneController.text;
      _address = _addressController.text;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حفظ التغييرات بنجاح'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final cardColor = isDark ? AppColors.surfaceAltDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    
    final children = ref.watch(childrenProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Standard App Sliver Header for design consistency
            AppSliverHeader(
              title: context.loc.profile,
              showChildSwitcher: false,
              automaticallyImplyLeading: true,
              trailing: _isEditing
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _saveDetails,
                      child: const Text(
                        'حفظ',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'GoogleSans',
                        ),
                      ),
                    )
                  : CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() => _isEditing = true),
                      child: Text(
                        'تعديل',
                        style: TextStyle(
                          color: isDark ? AppColors.accent : AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'GoogleSans',
                        ),
                      ),
                    ),
            ),
            
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar & Basic Info Header
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cardColor,
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : AppColors.border,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 54,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _pickedImagePath != null
                                      ? FileImage(File(_pickedImagePath!)) as ImageProvider
                                      : const NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=200') as ImageProvider,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _showAvatarPicker,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _parentName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontFamily: 'GoogleSans',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ولي أمر',
                            style: TextStyle(
                              fontSize: 13,
                              color: subTextColor,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'GoogleSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Account Information Card
                    _buildSectionLabel('معلومات الحساب', isDark),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.white10 : AppColors.border,
                        ),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          _buildEditableRow(
                            icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.duotone),
                            label: 'الرقم الوطني',
                            value: _nationalId,
                            controller: _addressController, // Dummy
                            isEditableField: false,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            textDirection: TextDirection.ltr,
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          _buildEditableRow(
                            icon: PhosphorIcons.user(PhosphorIconsStyle.duotone),
                            label: 'الاسم الكامل',
                            value: _parentName,
                            controller: _nameController,
                            isEditableField: _isEditing,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            validator: (v) => v!.isEmpty ? 'الرجاء إدخال الاسم الكامل' : null,
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          _buildEditableRow(
                            icon: PhosphorIcons.phone(PhosphorIconsStyle.duotone),
                            label: 'رقم الهاتف',
                            value: _phone,
                            controller: _phoneController,
                            isEditableField: _isEditing,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            validator: (v) => v!.isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          _buildEditableRow(
                            icon: PhosphorIcons.mapPin(PhosphorIconsStyle.duotone),
                            label: 'العنوان السكني',
                            value: _address,
                            controller: _addressController,
                            isEditableField: _isEditing,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            validator: (v) => v!.isEmpty ? 'الرجاء إدخال العنوان السكني' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Children Section
                    _buildSectionLabel('الطلاب المسجلين (الأبناء)', isDark),
                    const SizedBox(height: 12),
                    children.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? Colors.white10 : AppColors.border,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'لا يوجد أبناء مسجلين حالياً',
                                style: TextStyle(fontFamily: 'GoogleSans'),
                              ),
                            ),
                          )
                        : Column(
                            children: children.map((student) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : AppColors.border,
                                  ),
                                  boxShadow: isDark
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.01),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white10 : AppColors.primary.withValues(alpha: 0.06),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        PhosphorIcons.student(PhosphorIconsStyle.duotone),
                                        color: isDark ? AppColors.accent : AppColors.primary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                              fontFamily: 'GoogleSans',
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            student.grade,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: subTextColor,
                                              fontFamily: 'GoogleSans',
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'رقم القيد الدراسي: #${student.id}0928${student.id}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: subTextColor.withValues(alpha: 0.7),
                                              fontFamily: 'GoogleSans',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'نشط',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.success,
                                          fontFamily: 'GoogleSans',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : AppColors.primary.withValues(alpha: 0.8),
          fontFamily: 'GoogleSans',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEditableRow({
    required IconData icon,
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditableField,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    String? Function(String?)? validator,
  }) {
    return Row(
      crossAxisAlignment: isEditableField ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : AppColors.primary.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.accent : AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'GoogleSans',
                ),
              ),
              const SizedBox(height: 4),
              isEditableField
                  ? TextFormField(
                      controller: controller,
                      keyboardType: keyboardType,
                      validator: validator,
                      textDirection: textDirection,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'GoogleSans',
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: isDark ? Colors.white : AppColors.primary),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                        ),
                      ),
                    )
                  : Text(
                      value,
                      textDirection: textDirection,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'GoogleSans',
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
