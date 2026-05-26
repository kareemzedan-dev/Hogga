import 'package:equatable/equatable.dart';

import '../../../../shared/auth/data/models/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final String? avatarPath;

  const ProfileLoaded({required this.user, this.avatarPath});

  ProfileLoaded copyWith({UserModel? user, String? avatarPath}) {
    return ProfileLoaded(
      user: user ?? this.user,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  @override
  List<Object?> get props => [user, avatarPath];
}

class ProfileUpdating extends ProfileState {
  final UserModel user;
  const ProfileUpdating({required this.user});
  @override
  List<Object?> get props => [user];
}

class ProfileUpdateSuccess extends ProfileState {
  final UserModel user;
  const ProfileUpdateSuccess({required this.user});
  @override
  List<Object?> get props => [user];
}

class ProfileAvatarUpdating extends ProfileState {
  final UserModel user;
  const ProfileAvatarUpdating({required this.user});
  @override
  List<Object?> get props => [user];
}

class ProfileAvatarUpdateSuccess extends ProfileState {
  final UserModel user;
  const ProfileAvatarUpdateSuccess({required this.user});
  @override
  List<Object?> get props => [user];
}

class ProfilePasswordUpdating extends ProfileState {
  final UserModel user;
  const ProfilePasswordUpdating({required this.user});
  @override
  List<Object?> get props => [user];
}

class ProfilePasswordUpdateSuccess extends ProfileState {
  final String message;
  const ProfilePasswordUpdateSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
