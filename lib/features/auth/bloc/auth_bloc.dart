import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/local/hive_service.dart';
import '../data/auth_repository.dart';
import '../../favorites/bloc/favorites_bloc.dart';

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

  Map<String, dynamic>? _getUserFromStorage() {
    final name = HiveService.authBox.get('user_name');
    final phone = HiveService.authBox.get('user_phone');
    final id = HiveService.authBox.get('user_id');

    if (name == null && phone == null && id == null) return null;

    return {'full_name': name, 'phone': phone, 'id': id};
  }
}
