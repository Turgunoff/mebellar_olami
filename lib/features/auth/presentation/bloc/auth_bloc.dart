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
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
  }

  final AuthRepository _repository;
  final FavoritesBloc? _favoritesBloc;

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isOnboardingCompleted: state.isOnboardingCompleted));

    final onboardingCompleted = await _repository.isOnboardingCompleted();

    // If onboarding is not completed, emit AuthOnboardingRequired
    if (!onboardingCompleted) {
      emit(const AuthOnboardingRequired());
      return;
    }

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

    final result = await _repository.login(
      phone: event.phone,
      password: event.password,
    );

    result.fold(
      (failure) => emit(
        AuthFailure(
          message: failure.message,
          isOnboardingCompleted: state.isOnboardingCompleted,
        ),
      ),
      (response) => emit(
        AuthAuthenticated(
          token: response['token'] as String,
          user: response['user'] as Map<String, dynamic>?,
          isOnboardingCompleted: true,
        ),
      ),
    );

    // Trigger favorites sync after successful login if result is Right
    result.fold(
      (failure) => null,
      (response) => _favoritesBloc?.add(const SyncFavoritesEvent()),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isOnboardingCompleted: state.isOnboardingCompleted));

    final result = await _repository.register(
      fullName: event.fullName,
      phone: event.phone,
      password: event.password,
    );

    result.fold(
      (failure) => emit(
        AuthFailure(
          message: failure.message,
          isOnboardingCompleted: state.isOnboardingCompleted,
        ),
      ),
      (response) => emit(
        AuthAuthenticated(
          token: response['token'] as String,
          user: response['user'] as Map<String, dynamic>?,
          isOnboardingCompleted: true,
        ),
      ),
    );
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

    result.fold(
      (failure) => emit(
        AuthFailure(
          message: failure.message,
          isOnboardingCompleted: state.isOnboardingCompleted,
        ),
      ),
      (response) {
        if (event.isResend) {
          emit(
            AuthCodeResent(isOnboardingCompleted: state.isOnboardingCompleted),
          );
        } else {
          emit(
            AuthUnauthenticated(
              isOnboardingCompleted: state.isOnboardingCompleted,
            ),
          );
        }
      },
    );
  }

  Future<void> _onSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isOnboardingCompleted: state.isOnboardingCompleted));

    final result = await _repository.sendOtp(phone: event.phone);

    result.fold(
      (failure) => emit(
        AuthFailure(
          message: failure.message,
          isOnboardingCompleted: state.isOnboardingCompleted,
        ),
      ),
      (response) {
        if (event.isResend) {
          emit(
            AuthCodeResent(isOnboardingCompleted: state.isOnboardingCompleted),
          );
        } else {
          emit(
            AuthUnauthenticated(
              isOnboardingCompleted: state.isOnboardingCompleted,
            ),
          );
        }
      },
    );
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

    result.fold(
      (failure) => emit(
        AuthFailure(
          message: failure.message,
          isOnboardingCompleted: state.isOnboardingCompleted,
        ),
      ),
      (response) => emit(
        AuthUnauthenticated(isOnboardingCompleted: state.isOnboardingCompleted),
      ),
    );
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

    result.fold(
      (failure) => emit(
        AuthFailure(
          message: failure.message,
          isOnboardingCompleted: state.isOnboardingCompleted,
        ),
      ),
      (response) => emit(
        AuthUnauthenticated(isOnboardingCompleted: state.isOnboardingCompleted),
      ),
    );
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('✅ AuthBloc: CompleteOnboarding event received');

    // Save to repository first
    await _repository.setOnboardingCompleted();
    print('✅ AuthBloc: Onboarding saved to storage');

    // Update state immediately with onboarding completed
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      print('✅ AuthBloc: Emitting AuthAuthenticated with onboarding completed');
      emit(
        AuthAuthenticated(
          token: currentState.token,
          user: currentState.user,
          isOnboardingCompleted: true,
        ),
      );
    } else {
      print(
        '✅ AuthBloc: Emitting AuthUnauthenticated with onboarding completed',
      );
      emit(AuthUnauthenticated(isOnboardingCompleted: true));
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
