/// Excepción base para errores de la aplicación
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Error al acceder a la base de datos local
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

/// Error al parsear/serializar datos
class SerializationException extends AppException {
  const SerializationException(super.message, {super.code});
}

/// Error de validación de datos
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    super.code,
    this.fieldErrors,
  });
}

/// Error cuando no se encuentra un recurso
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});
}

/// Error de autenticación (para futura migración)
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Error de caché local
class CacheException extends AppException {
  const CacheException({required String message, String? code})
      : super(message, code: code);
}
