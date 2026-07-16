import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/providers/parent_provider.dart';
import '../../../../core/models/parent_profile.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/extensions/localization_extension.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Real picked image path
  String? _pickedImagePath;
  
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _nationalIdController;

  bool _initialized = false;

  void _initializeFields(ParentProfile parent) {
    if (!_initialized && parent.id.isNotEmpty) {
      _nameController.text = parent.name;
      _phoneController.text = parent.phoneNumber;
      _initialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _nationalIdController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nationalIdController.dispose();
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

  Future<void> _uploadAvatar(String path) async {
    final dio = ref.read(apiClientProvider);
    final parent = ref.read(currentParentProvider);
    final parentNotifier = ref.read(currentParentProvider.notifier);

    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          path,
          filename: path.split('/').last,
        ),
      });

      final response = await dio.post(
        'user/update-photo',
        data: formData,
      );

      if (response.data != null && response.data['success'] == true) {
        final newUrl = response.data['photo_url'];
        
        await parentNotifier.setProfile(
          id: parent.id,
          name: parent.name,
          phoneNumber: parent.phoneNumber,
          nationalId: parent.nationalId,
          avatarUrl: newUrl,
        );

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
      debugPrint('Error uploading avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء رفع الصورة الشخصية: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
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
        if (!mounted) return;
        setState(() {
          _pickedImagePath = image.path;
        });
        
        await _uploadAvatar(image.path);
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

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;
    
    final parent = ref.read(currentParentProvider);
    if (parent.id.isEmpty) return;

    final dio = ref.read(apiClientProvider);
    final parentNotifier = ref.read(currentParentProvider.notifier);

    setState(() {
      _isEditing = false;
    });

    try {
      final response = await dio.put('parents/${parent.id}', data: {
        'name_ar': _nameController.text,
        'phone': _phoneController.text,
      });

      if (response.data != null && response.data['success'] == true) {
        final updatedParent = response.data['parent'];
        
        await parentNotifier.setProfile(
          id: parent.id,
          name: updatedParent['name_ar'] ?? _nameController.text,
          phoneNumber: updatedParent['phone'] ?? _phoneController.text,
          nationalId: parent.nationalId,
          avatarUrl: parent.avatarUrl,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم حفظ التغييرات بنجاح'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating parent profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ التغييرات: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    bool isSubmittingPassword = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final dialogBgColor = isDark ? AppColors.surfaceAltDark : Colors.white;
            final textStyle = TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              fontFamily: 'GoogleSans',
            );

            return AlertDialog(
              backgroundColor: dialogBgColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                'تغيير كلمة المرور',
                style: textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              content: Form(
                key: dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: true,
                      style: textStyle,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور الحالية',
                        labelStyle: TextStyle(fontFamily: 'GoogleSans', fontSize: 13),
                        isDense: true,
                      ),
                      validator: (v) => v!.isEmpty ? 'الرجاء إدخال كلمة المرور الحالية' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      style: textStyle,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور الجديدة',
                        labelStyle: TextStyle(fontFamily: 'GoogleSans', fontSize: 13),
                        isDense: true,
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return 'الرجاء إدخال كلمة المرور الجديدة';
                        if (v.length < 6) return 'يجب أن لا تقل عن 6 أحرف';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: textStyle,
                      decoration: const InputDecoration(
                        labelText: 'تأكيد كلمة المرور الجديدة',
                        labelStyle: TextStyle(fontFamily: 'GoogleSans', fontSize: 13),
                        isDense: true,
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return 'الرجاء تأكيد كلمة المرور الجديدة';
                        if (v != newPasswordController.text) return 'كلمات المرور غير متطابقة';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmittingPassword ? null : () => Navigator.pop(context),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'GoogleSans',
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSubmittingPassword
                      ? null
                      : () async {
                          if (!dialogFormKey.currentState!.validate()) return;
                          setDialogState(() => isSubmittingPassword = true);

                          try {
                            final dio = ref.read(apiClientProvider);
                            final response = await dio.post('user/update-password', data: {
                              'current_password': currentPasswordController.text,
                              'new_password': newPasswordController.text,
                              'new_password_confirmation': confirmPasswordController.text,
                            });

                            if (response.data != null && response.data['success'] == true) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('تم تغيير كلمة المرور بنجاح'),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response.data['message'] ?? 'فشل تغيير كلمة المرور'),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('كلمة المرور الحالية غير صحيحة'),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          } finally {
                            setDialogState(() => isSubmittingPassword = false);
                          }
                        },
                  child: isSubmittingPassword
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'حفظ',
                          style: TextStyle(fontFamily: 'GoogleSans', color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Address is loaded from backend or defaults to empty

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final cardColor = isDark ? AppColors.surfaceAltDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    
    final parent = ref.watch(currentParentProvider);
    _initializeFields(parent);
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
                                      : (() {
                                          final normalized = AppConstants.normalizeUrl(parent.avatarUrl);
                                          return (normalized != null && normalized.length > 5
                                              ? NetworkImage(normalized) as ImageProvider
                                              : const AssetImage('assets/icons/app_icon.jpeg') as ImageProvider);
                                        })(),
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
                            parent.name,
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
                            label: 'الرقم الوطني (اسم المستخدم)',
                            value: parent.nationalId,
                            controller: _nationalIdController,
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
                            value: parent.name,
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
                            value: parent.phoneNumber,
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
                            value: _addressController.text.isEmpty ? 'غير محدد' : _addressController.text,
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
                    const SizedBox(height: 32),
                    _buildSectionLabel('الأمان والحماية', isDark),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white10 : AppColors.border,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : AppColors.primary.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            PhosphorIcons.lock(PhosphorIconsStyle.duotone),
                            color: isDark ? AppColors.accent : AppColors.primary,
                          ),
                        ),
                        title: const Text(
                          'تغيير كلمة المرور',
                          style: TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'تحديث كلمة مرور الحساب الخاصة بك',
                          style: TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 11,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: _showChangePasswordDialog,
                      ),
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
