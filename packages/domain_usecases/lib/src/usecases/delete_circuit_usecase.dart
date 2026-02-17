import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Deletes a `Circuit` using the repository `delete` method.
class DeleteCircuitUseCase {
  final CircuitRepository circuitRepository;

  DeleteCircuitUseCase({required this.circuitRepository});

  TaskEither<Failure, Unit> call({required CircuitHandle handle}) {
    return circuitRepository.delete(handle: handle);
  }
}
