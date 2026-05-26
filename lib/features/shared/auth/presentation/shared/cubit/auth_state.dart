import 'package:equatable/equatable.dart';
import 'package:hogga/features/shared/auth/data/models/user_model.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}
final class AuthVerified extends AuthState {}

final class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);
  
  @override
  List<Object?> get props => [user];
}

final class AuthOperationSuccess extends AuthState {
  final String message;
  const AuthOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

final class Unauthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}

final class AuthNeedVerification extends AuthState {
  final String email;
  const AuthNeedVerification(this.email);
  @override
  List<Object?> get props => [email];
}

final class AuthResetPasswordOtpVerified extends AuthState {
  final String otp;
  const AuthResetPasswordOtpVerified(this.otp);
  @override
  List<Object?> get props => [otp];
}

