import 'package:equatable/equatable.dart';

/// Clase base para representar fallos en la capa de dominio
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Fallo genérico de base de datos
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

/// Fallo al validar datos
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(
    super.message, {
    super.code,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Fallo cuando no se encuentra un recurso
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

/// Fallo inesperado
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code});
}

/// Fallo de autenticación (para futura migración)
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Fallo de caché local
class CacheFailure extends Failure {
  const CacheFailure({required String message, String? code})
      : super(message, code: code);
}
