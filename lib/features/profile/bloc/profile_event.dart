part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  final String? fullName;
  final File? avatarFile;

  const UpdateProfile({this.fullName, this.avatarFile});

  @override
  List<Object?> get props => [fullName, avatarFile];
}

class DeleteAccount extends ProfileEvent {
  const DeleteAccount();
}

class RequestPhoneChange extends ProfileEvent {
  final String newPhone;

  const RequestPhoneChange({required this.newPhone});

  @override
  List<Object?> get props => [newPhone];
}

class VerifyPhoneChange extends ProfileEvent {
  final String newPhone;
  final String code;

  const VerifyPhoneChange({required this.newPhone, required this.code});

  @override
  List<Object?> get props => [newPhone, code];
}

class RequestEmailChange extends ProfileEvent {
  final String newEmail;

  const RequestEmailChange({required this.newEmail});

  @override
  List<Object?> get props => [newEmail];
}

class VerifyEmailChange extends ProfileEvent {
  final String newEmail;
  final String code;

  const VerifyEmailChange({required this.newEmail, required this.code});

  @override
  List<Object?> get props => [newEmail, code];
}
