part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.phone,
    required this.password,
  });

  final String phone;
  final String password;

  @override
  List<Object?> get props => [phone, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.fullName,
    required this.phone,
    required this.password,
  });

  final String fullName;
  final String phone;
  final String password;

  @override
  List<Object?> get props => [fullName, phone, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
