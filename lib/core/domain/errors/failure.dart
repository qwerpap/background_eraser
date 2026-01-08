import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}

class InsufficientCreditsFailure extends Failure {
  const InsufficientCreditsFailure([super.message]);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([super.message]);
}

class InvalidFileFailure extends Failure {
  const InvalidFileFailure([super.message]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message]);
}

