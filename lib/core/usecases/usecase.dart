import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Clase base para todos los casos de uso
/// T = tipo de retorno exitoso
/// Params = tipo de parámetros de entrada
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Clase para casos de uso que no requieren parámetros
class NoParams {
  const NoParams();
}
