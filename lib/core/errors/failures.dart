import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class VerificationRequiredFailure extends Failure {
  const VerificationRequiredFailure()
      : super('verification_required');
}

class OrderConflictFailure extends Failure {
  final String suggestedTime;
  final String unavailableProductName;

  const OrderConflictFailure(
    super.message, {
    required this.suggestedTime,
    required this.unavailableProductName,
  });

  @override
  List<Object> get props => [message, suggestedTime, unavailableProductName];
}
