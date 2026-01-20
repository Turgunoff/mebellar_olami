part of 'profile_bloc.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  deleting,
  deleted,
  error,
}

enum PhoneChangeStatus { initial, sending, codeSent, verifying, success, error }

enum EmailChangeStatus { initial, sending, codeSent, verifying, success, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final PhoneChangeStatus phoneChangeStatus;
  final EmailChangeStatus emailChangeStatus;
  final String? userId;
  final String? fullName;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final String? createdAt;
  final String? pendingPhone;
  final String? pendingEmail;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.phoneChangeStatus = PhoneChangeStatus.initial,
    this.emailChangeStatus = EmailChangeStatus.initial,
    this.userId,
    this.fullName,
    this.phone,
    this.email,
    this.avatarUrl,
    this.createdAt,
    this.pendingPhone,
    this.pendingEmail,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == ProfileStatus.loading;
  bool get isLoaded => status == ProfileStatus.loaded;
  bool get hasError => status == ProfileStatus.error;
  bool get isDeleted => status == ProfileStatus.deleted;

  String? get fullAvatarUrl {
    if (avatarUrl == null || avatarUrl!.isEmpty) return null;
    if (avatarUrl!.startsWith('/')) {
      return 'http://45.93.201.167:8081$avatarUrl';
    }
    return avatarUrl;
  }

  ProfileState copyWith({
    ProfileStatus? status,
    PhoneChangeStatus? phoneChangeStatus,
    EmailChangeStatus? emailChangeStatus,
    String? userId,
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    String? createdAt,
    String? pendingPhone,
    String? pendingEmail,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      phoneChangeStatus: phoneChangeStatus ?? this.phoneChangeStatus,
      emailChangeStatus: emailChangeStatus ?? this.emailChangeStatus,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      pendingPhone: pendingPhone,
      pendingEmail: pendingEmail,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    phoneChangeStatus,
    emailChangeStatus,
    userId,
    fullName,
    phone,
    email,
    avatarUrl,
    createdAt,
    pendingPhone,
    pendingEmail,
    errorMessage,
    successMessage,
  ];
}
