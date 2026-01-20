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
  const AuthLoginRequested({required this.phone, required this.password});

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

class AuthForgotPasswordRequested extends AuthEvent {
  const AuthForgotPasswordRequested({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class AuthSendOtpRequested extends AuthEvent {
  const AuthSendOtpRequested({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class AuthResetPasswordRequested extends AuthEvent {
  const AuthResetPasswordRequested({
    required this.phone,
    required this.code,
    required this.newPassword,
  });

  final String phone;
  final String code;
  final String newPassword;

  @override
  List<Object?> get props => [phone, code, newPassword];
}

class AuthVerifyOtpRequested extends AuthEvent {
  const AuthVerifyOtpRequested({required this.phone, required this.code});

  final String phone;
  final String code;

  @override
  List<Object?> get props => [phone, code];
}
