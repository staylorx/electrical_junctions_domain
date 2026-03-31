import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Updates a `Circuit` by using the repository `update` method.
///
/// Following the UseCase standard, returns CircuitWithHandle to provide
/// the handle for UI layer operations.
class UpdateCircuitUseCase {
  final CircuitRepository circuitRepository;

  UpdateCircuitUseCase({required this.circuitRepository});

  TaskEither<Failure, CircuitWithHandle> call({
    required Circuit circuit,
    required CircuitHandle handle,
  }) {
    return circuitRepository.update(item: circuit, handle: handle);
  }
}
