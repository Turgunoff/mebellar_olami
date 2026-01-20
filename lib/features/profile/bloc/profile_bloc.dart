import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepository(),
      super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<DeleteAccount>(_onDeleteAccount);
    on<RequestPhoneChange>(_onRequestPhoneChange);
    on<VerifyPhoneChange>(_onVerifyPhoneChange);
    on<RequestEmailChange>(_onRequestEmailChange);
    on<VerifyEmailChange>(_onVerifyEmailChange);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final response = await _repository.getProfile();

      if (response.success && response.user != null) {
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            userId: response.user!['id']?.toString(),
            fullName: response.user!['full_name'],
            phone: response.user!['phone'],
            email: response.user!['email'],
            avatarUrl: response.user!['avatar_url'],
            createdAt: response.user!['created_at'],
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: response.message ?? 'Profilni yuklashda xatolik',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Xatolik yuz berdi: $e',
        ),
      );
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    try {
      final response = await _repository.updateProfile(
        fullName: event.fullName,
        avatarFile: event.avatarFile,
      );

      if (response.success) {
        String? newFullName = state.fullName;
        String? newAvatarUrl = state.avatarUrl;
        String? newEmail = state.email;

        if (response.user != null) {
          newFullName = response.user!['full_name'];
          newAvatarUrl = response.user!['avatar_url'];
          newEmail = response.user!['email'];
        }

        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            fullName: newFullName,
            avatarUrl: newAvatarUrl,
            email: newEmail,
            successMessage: 'Profil muvaffaqiyatli yangilandi',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: response.message ?? 'Profilni yangilashda xatolik',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Xatolik yuz berdi: $e',
        ),
      );
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.deleting));

    try {
      final response = await _repository.deleteAccount();

      if (response.success) {
        emit(
          const ProfileState(
            status: ProfileStatus.deleted,
            successMessage: 'Hisob muvaffaqiyatli o\'chirildi',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: response.message ?? 'Hisobni o\'chirishda xatolik',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Xatolik yuz berdi: $e',
        ),
      );
    }
  }

  Future<void> _onRequestPhoneChange(
    RequestPhoneChange event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(phoneChangeStatus: PhoneChangeStatus.sending));

    try {
      final response = await _repository.requestPhoneChange(event.newPhone);

      if (response.success) {
        emit(
          state.copyWith(
            phoneChangeStatus: PhoneChangeStatus.codeSent,
            pendingPhone: event.newPhone,
          ),
        );
      } else {
        emit(
          state.copyWith(
            phoneChangeStatus: PhoneChangeStatus.error,
            errorMessage: response.message ?? 'OTP yuborishda xatolik',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          phoneChangeStatus: PhoneChangeStatus.error,
          errorMessage: 'Xatolik yuz berdi: $e',
        ),
      );
    }
  }

  Future<void> _onVerifyPhoneChange(
    VerifyPhoneChange event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(phoneChangeStatus: PhoneChangeStatus.verifying));

    try {
      final response = await _repository.verifyPhoneChange(
        event.newPhone,
        event.code,
      );

      if (response.success) {
        String? newPhone = state.phone;
        if (response.user != null) {
          newPhone = response.user!['phone'];
        }

        emit(
          state.copyWith(
            phoneChangeStatus: PhoneChangeStatus.success,
            phone: newPhone,
            pendingPhone: null,
            successMessage: 'Telefon raqami muvaffaqiyatli o\'zgartirildi',
          ),
        );
      } else {
        emit(
          state.copyWith(
            phoneChangeStatus: PhoneChangeStatus.error,
            errorMessage: response.message ?? 'Kodni tasdiqlashda xatolik',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          phoneChangeStatus: PhoneChangeStatus.error,
          errorMessage: 'Xatolik yuz berdi: $e',
        ),
      );
    }
  }

  Future<void> _onRequestEmailChange(
    RequestEmailChange event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(emailChangeStatus: EmailChangeStatus.sending));

    try {
      final response = await _repository.requestEmailChange(event.newEmail);

      if (response.success) {
        emit(
          state.copyWith(
            emailChangeStatus: EmailChangeStatus.codeSent,
            pendingEmail: event.newEmail,
          ),
        );
      } else {
        emit(
          state.copyWith(
            emailChangeStatus: EmailChangeStatus.error,
            errorMessage: response.message ?? 'OTP yuborishda xatolik',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          emailChangeStatus: EmailChangeStatus.error,
          errorMessage: 'Xatolik yuz berdi: $e',
        ),
      );
    }
  }

  Future<void> _onVerifyEmailChange(
    VerifyEmailChange event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(emailChangeStatus: EmailChangeStatus.verifying));

    try {
      final response = await _repository.verifyEmailChange(
        event.newEmail,
        event.code,
      );

      if (response.success) {
        String? newEmail = state.email;
        if (response.user != null) {
          newEmail = response.user!['email'];
        }

        emit(
          state.copyWith(
            emailChangeStatus: EmailChangeStatus.success,
            email: newEmail,
            pendingEmail: null,
            successMessage: 'Email muvaffaqiyatli o\'zgartirildi',
          ),
        );
      } else {
        emit(
          state.copyWith(
            emailChangeStatus: EmailChangeStatus.error,
            errorMessage: response.message ?? 'Kodni tasdiqlashda xatolik',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          emailChangeStatus: EmailChangeStatus.error,
          errorMessage: 'Xatolik yuz berdi: $e',
        ),
      );
    }
  }
}
