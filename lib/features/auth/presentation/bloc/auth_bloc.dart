import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/local/hive_service.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository repository, FavoritesBloc? favoritesBloc})
    : _repository = repository,
      _favoritesBloc = favoritesBloc,
      super(const AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthSendOtpRequested>(_onSendOtpRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
  }

  final AuthRepository _repository;
  final FavoritesBloc? _favoritesBloc;

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isOnboardingCompleted: state.isOnboardingCompleted));

    final onboardingCompleted = await _repository.isOnboardingCompleted();
    final token = await _repository.getSavedToken();
    final user = _getUserFromStorage();

    if (token != null && token.isNotEmpty) {
      emit(
        AuthAuthenticated(
          token: token,
          user: user,
          isOnboardingCompleted: onboardingCompleted,
        ),
      );
    } else {
      emit(AuthUnauthenticated(isOnboardingCompleted: onboardingCompleted));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isOnboardingCompleted: state.isOnboardingCompleted));

    try {
      final response = await _repository.login(
        phone: event.phone,
        password: event.password,
      );

      emit(
        AuthAuthenticated(
          token: response['token'] as String,
          user: response['user'] as Map<String, dynamic>?,
          isOnboardingCompleted: true,
        ),
      );

      // Trigger favorites sync after successful login
      _favoritesBloc?.add(const SyncFavoritesEvent());
    } catch (e) {
      emit(
        AuthFailure(
          message: e.toString().replaceAll('Exception: ', ''),
          isOnboardingCompleted: state.isOnboardingCompleted,
        ),
      );
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isOnboardingCompleted: state.isOnboardingCompleted));

    try {
      final response = await _repository.register(
        fullName: event.fullName,
        phone: event.phone,
        password: event.password,
      );

      emit(
        AuthAuthenticated(
          token: response['token'] as String,
          user: response['user'] as Map<String, dynamic>?,
          isOnboardingCompleted: true,
        ),
      );

      // Trigger favorites sync after successful registration
      _favoritesBloc?.add(const SyncFavoritesEvent());
    } catch (e) {
      emit(
        AuthFailure(
          message: e.toString().replaceAll('Exception: ', ''),
          isOnboardingCompleted: state.isOnboardingCompleted,
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.clearSession();
    final onboardingCompleted = await _repository.isOnboardingCompleted();
    emit(AuthUnauthenticated(isOnboardingCompleted: onboardingCompleted));
  }

  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isOnboardingCompleted: state.isOnboardingCompleted));

    final result = await _repository.forgotPassword(phone: event.phone);

    if (result['success'] == true) {
      emit(
        AuthUnauthenticated(isOnboardingCompleted: state.isOnboardingCompleted),
      );
    } else {
      emit(
        AuthFailure(
          message: result['message'] ?? 'Failed to send reset code',
          isOnboardingCompleted: state.isOnboardingCompleted,
        ),
      );
    }
  }

  Future<void> _onSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isOnboardingCompleted: state.isOnboardingCompleted));

    final result = await _repository.sendOtp(phone: event.phone);

    if (result['success'] == true) {
      emit(
        AuthUnauthenticated(isOnboardingCompleted: state.isOnboardingCompleted),
      );
    } else {
      emit(
        AuthFailure(
          message: result['message'] ?? 'Failed to send OTP',
          isOnboardingCompleted: state.isOnboardingCompleted,
        ),
      );
    }
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isOnboardingCompleted: state.isOnboardingCompleted));

    final result = await _repository.resetPassword(
      phone: event.phone,
      code: event.code,
      newPassword: event.newPassword,
    );

    if (result['success'] == true) {
      emit(
        AuthUnauthenticated(isOnboardingCompleted: state.isOnboardingCompleted),
      );
    } else {
      emit(
        AuthFailure(
          message: result['message'] ?? 'Failed to reset password',
          isOnboardingCompleted: state.isOnboardingCompleted,
        ),
      );
    }
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isOnboardingCompleted: state.isOnboardingCompleted));

    final result = await _repository.verifyOtp(
      phone: event.phone,
      code: event.code,
    );

    if (result['success'] == true) {
      emit(
        AuthUnauthenticated(isOnboardingCompleted: state.isOnboardingCompleted),
      );
    } else {
      emit(
        AuthFailure(
          message: result['message'] ?? 'Failed to verify OTP',
          isOnboardingCompleted: state.isOnboardingCompleted,
        ),
      );
    }
  }

  Map<String, dynamic>? _getUserFromStorage() {
    final name = HiveService.authBox.get('user_name');
    final phone = HiveService.authBox.get('user_phone');
    final id = HiveService.authBox.get('user_id');

    if (name == null && phone == null && id == null) return null;

    return {'full_name': name, 'phone': phone, 'id': id};
  }
}
