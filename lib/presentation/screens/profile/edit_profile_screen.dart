import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';

/// Profil tahrirlash ekrani - Professional dizayn
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Joriy ma'lumotlarni yuklash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      _nameController.text = userProvider.fullName ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Rasm tanlash
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Rasm tanlashda xatolik: $e');
      _showSnackBar('Rasm tanlashda xatolik yuz berdi', isError: true);
    }
  }

  /// Profilni saqlash (ism va avatar)
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty && _selectedImage == null) {
      _showSnackBar('Hech narsa o\'zgarmadi', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.updateProfile(
      newName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      avatarFile: _selectedImage,
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      _showSnackBar('Profil muvaffaqiyatli yangilandi');
      Navigator.pop(context, true);
    } else if (mounted) {
      _showSnackBar(userProvider.errorMessage ?? 'Xatolik yuz berdi', isError: true);
    }
  }

  /// Telefon o'zgartirish oynasi
  void _showChangePhoneDialog() {
    final phoneController = TextEditingController();
    final codeController = TextEditingController();
    bool isOtpSent = false;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                isOtpSent ? 'Tasdiqlash kodi' : 'Telefon raqamni o\'zgartirish',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isOtpSent
                    ? 'Yangi telefon raqamingizga yuborilgan kodni kiriting'
                    : 'Yangi telefon raqamingizni kiriting',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Input
              if (!isOtpSent)
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Yangi telefon raqam',
                    hintText: '+998 90 123 45 67',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Tasdiqlash kodi',
                    hintText: '12345',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!isOtpSent) {
                            // OTP yuborish
                            if (phoneController.text.trim().isEmpty) {
                              _showSnackBar('Telefon raqam kiriting', isError: true);
                              return;
                            }

                            setModalState(() => isLoading = true);
                            final userProvider = context.read<UserProvider>();
                            final success = await userProvider.requestPhoneChange(
                              phoneController.text.trim(),
                            );
                            setModalState(() => isLoading = false);

                            if (success) {
                              setModalState(() => isOtpSent = true);
                              _showSnackBar('Tasdiqlash kodi yuborildi');
                            } else {
                              _showSnackBar(
                                userProvider.errorMessage ?? 'Xatolik',
                                isError: true,
                              );
                            }
                          } else {
                            // OTP tasdiqlash
                            if (codeController.text.trim().length < 5) {
                              _showSnackBar('5 raqamli kodni kiriting', isError: true);
                              return;
                            }

                            setModalState(() => isLoading = true);
                            final userProvider = context.read<UserProvider>();
                            final success = await userProvider.verifyPhoneChange(
                              phoneController.text.trim(),
                              codeController.text.trim(),
                            );
                            setModalState(() => isLoading = false);

                            if (success && mounted) {
                              Navigator.pop(context);
                              _showSnackBar('Telefon raqam muvaffaqiyatli o\'zgartirildi');
                            } else {
                              _showSnackBar(
                                userProvider.errorMessage ?? 'Xatolik',
                                isError: true,
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isOtpSent ? 'Tasdiqlash' : 'Kod yuborish',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Email o'zgartirish oynasi
  void _showChangeEmailDialog() {
    final emailController = TextEditingController();
    final codeController = TextEditingController();
    bool isOtpSent = false;
    bool isLoading = false;

    final userProvider = context.read<UserProvider>();
    final hasEmail = userProvider.email != null && userProvider.email!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                isOtpSent
                    ? 'Tasdiqlash kodi'
                    : hasEmail
                        ? 'Emailni o\'zgartirish'
                        : 'Email qo\'shish',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isOtpSent
                    ? 'Yangi email manzilingizga yuborilgan kodni kiriting'
                    : 'Yangi email manzilingizni kiriting',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Input
              if (!isOtpSent)
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email manzil',
                    hintText: 'example@mail.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Tasdiqlash kodi',
                    hintText: '12345',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!isOtpSent) {
                            // OTP yuborish
                            if (emailController.text.trim().isEmpty) {
                              _showSnackBar('Email manzil kiriting', isError: true);
                              return;
                            }

                            // Email validatsiya
                            if (!emailController.text.contains('@')) {
                              _showSnackBar('To\'g\'ri email kiriting', isError: true);
                              return;
                            }

                            setModalState(() => isLoading = true);
                            final userProvider = context.read<UserProvider>();
                            final success = await userProvider.requestEmailChange(
                              emailController.text.trim(),
                            );
                            setModalState(() => isLoading = false);

                            if (success) {
                              setModalState(() => isOtpSent = true);
                              _showSnackBar('Tasdiqlash kodi yuborildi');
                            } else {
                              _showSnackBar(
                                userProvider.errorMessage ?? 'Xatolik',
                                isError: true,
                              );
                            }
                          } else {
                            // OTP tasdiqlash
                            if (codeController.text.trim().length < 5) {
                              _showSnackBar('5 raqamli kodni kiriting', isError: true);
                              return;
                            }

                            setModalState(() => isLoading = true);
                            final userProvider = context.read<UserProvider>();
                            final success = await userProvider.verifyEmailChange(
                              emailController.text.trim(),
                              codeController.text.trim(),
                            );
                            setModalState(() => isLoading = false);

                            if (success && mounted) {
                              Navigator.pop(context);
                              _showSnackBar('Email muvaffaqiyatli ${hasEmail ? "o'zgartirildi" : "qo'shildi"}');
                            } else {
                              _showSnackBar(
                                userProvider.errorMessage ?? 'Xatolik',
                                isError: true,
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isOtpSent ? 'Tasdiqlash' : 'Kod yuborish',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profilni tahrirlash'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar section
              _buildAvatarSection(userProvider).animate().fadeIn().scale(
                    begin: const Offset(0.9, 0.9),
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 32),

              // Full Name
              _buildNameField().animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
              const SizedBox(height: 24),

              // Phone (read-only with change button)
              _buildPhoneField(userProvider)
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideX(begin: -0.1),
              const SizedBox(height: 16),

              // Email (with add/change button)
              _buildEmailField(userProvider)
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideX(begin: -0.1),
              const SizedBox(height: 40),

              // Save button
              CustomButton(
                text: 'Saqlash',
                icon: Icons.check_rounded,
                isLoading: _isSaving,
                onPressed: _saveProfile,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  /// Avatar qismi
  Widget _buildAvatarSection(UserProvider userProvider) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withValues(alpha: 0.5),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    )
                  : userProvider.fullAvatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: userProvider.fullAvatarUrl!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(strokeWidth: 2),
                          errorWidget: (context, url, error) => _buildInitialAvatar(userProvider),
                        )
                      : _buildInitialAvatar(userProvider),
            ),
          ),
          // Edit badge
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 3),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar(UserProvider userProvider) {
    final name = userProvider.fullName ?? '';
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'F',
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Ism kiritish maydoni
  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'To\'liq ism',
          hintText: 'Ismingizni kiriting',
          prefixIcon: const Icon(Icons.person_outline),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
      ),
    );
  }

  /// Telefon maydoni (read-only)
  Widget _buildPhoneField(UserProvider userProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.phone_outlined, color: AppColors.primary),
        ),
        title: const Text(
          'Telefon raqam',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        subtitle: Text(
          userProvider.phone ?? 'Kiritilmagan',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: TextButton(
          onPressed: _showChangePhoneDialog,
          child: const Text('O\'zgartirish'),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// Email maydoni
  Widget _buildEmailField(UserProvider userProvider) {
    final hasEmail = userProvider.email != null && userProvider.email!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.email_outlined, color: AppColors.primary),
        ),
        title: const Text(
          'Email',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        subtitle: Text(
          hasEmail ? userProvider.email! : 'Kiritilmagan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: hasEmail ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        trailing: TextButton(
          onPressed: _showChangeEmailDialog,
          child: Text(hasEmail ? 'O\'zgartirish' : 'Qo\'shish'),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
