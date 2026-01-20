import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../bloc/profile_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

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
      final profileState = context.read<ProfileBloc>().state;
      _nameController.text = profileState.fullName ?? '';
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
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rasm tanlashda xatolik: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Kamera orqali rasmga olish
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rasmga olishda xatolik: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Rasm tanlash variantlari
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Avatar tanlang',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Galeriyadan tanlash'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Kameraga olish'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Saqlash
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      context.read<ProfileBloc>().add(
        UpdateProfile(
          fullName: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
          avatarFile: _selectedImage,
        ),
      );

      // Natijani kutish
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        final profileState = context.read<ProfileBloc>().state;

        if (profileState.status == ProfileStatus.loaded &&
            profileState.successMessage != null) {
          // Muvaffaqiyat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profileState.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else if (profileState.hasError) {
          // Xatolik
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profileState.errorMessage ?? 'Xatolik yuz berdi'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profilni tahrirlash'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Text('Saqlash'),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          return BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state.status == ProfileStatus.updating) {
                setState(() => _isSaving = true);
              } else {
                setState(() => _isSaving = false);
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar qismi
                    _buildAvatarSection(profileState).animate().fadeIn(),
                    const SizedBox(height: 30),

                    // Asosiy ma'lumotlar
                    _buildPersonalInfoSection().animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 30),

                    // Saqlash tugmasi
                    _buildSaveButton().animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Avatar qismi
  Widget _buildAvatarSection(ProfileState profileState) {
    final avatarUrl = profileState.fullAvatarUrl;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : avatarUrl != null
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.white,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Avatarni o\'zgartirish uchun teging',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Shaxsiy ma'lumotlar qismi
  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shaxsiy ma\'lumotlar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Ism
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Ismingiz',
              hintText: 'Ismingizni kiriting',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.lightGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Iltimos, ismingizni kiriting';
              }
              if (value.trim().length < 2) {
                return 'Ism kamida 2 ta belgidan iborat bo\'lishi kerak';
              }
              return null;
            },
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
          ),
          const SizedBox(height: 16),

          // Telefon raqami (faqat ko'rsatish, o'zgartirib bo'lmaydi)
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final phone = (authState is AuthAuthenticated)
                  ? (authState.user?['phone'] as String? ?? '')
                  : '';

              return TextFormField(
                initialValue: phone,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Telefon raqami',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  helperText:
                      'Telefon raqamini o\'zgartirish uchun admin bilan bog\'laning',
                  helperStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Saqlash tugmasi
  Widget _buildSaveButton() {
    return CustomButton(
      text: 'Saqlash',
      onPressed: _isSaving ? null : _saveProfile,
      isLoading: _isSaving,
    );
  }
}
