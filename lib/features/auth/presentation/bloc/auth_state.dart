part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState({this.isOnboardingCompleted = false});

  final bool isOnboardingCompleted;

  @override
  List<Object?> get props => [isOnboardingCompleted];
}

class AuthInitial extends AuthState {
  const AuthInitial({super.isOnboardingCompleted});
}

class AuthLoading extends AuthState {
  const AuthLoading({required super.isOnboardingCompleted});
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.token,
    this.user,
    required super.isOnboardingCompleted,
  });

  final String token;
  final Map<String, dynamic>? user;

  @override
  List<Object?> get props => [token, user, isOnboardingCompleted];
}

class AuthOnboardingRequired extends AuthState {
  const AuthOnboardingRequired() : super(isOnboardingCompleted: false);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({required super.isOnboardingCompleted});
}

class AuthFailure extends AuthState {
  const AuthFailure({
    required this.message,
    required super.isOnboardingCompleted,
  });

  final String message;

  @override
  List<Object?> get props => [message, isOnboardingCompleted];
}

/// Foydalanuvchi allaqachon mavjud bo'lganda (409 Conflict) chiqariladigan state.
/// Bu Sellerlar o'zlarining mavjud raqamlari bilan Xaridor ilovasiga kirishlari uchun muhim.
class AuthUserExists extends AuthState {
  const AuthUserExists({
    required this.phone,
    required this.message,
    required super.isOnboardingCompleted,
  });

  final String phone;
  final String message;

  @override
  List<Object?> get props => [phone, message, isOnboardingCompleted];
}

/// Kod qayta yuborilganda chiqariladigan state.
/// Bu holat faqat kod qayta yuborilganda ishlatiladi va navigatsiya qilmaydi.
class AuthCodeResent extends AuthState {
  const AuthCodeResent({required super.isOnboardingCompleted});
}

class AuthGuest extends AuthState {
  const AuthGuest({super.isOnboardingCompleted = true});

  @override
  List<Object?> get props => [isOnboardingCompleted];
}
