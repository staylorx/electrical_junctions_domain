import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for viewing the details of a circuit.
///
/// Following the UseCase standard, returns CircuitWithHandle to provide
/// the handle for UI layer operations.
class ViewCircuitDetailsUseCase {
  final CircuitRepository circuitRepository;

  /// Creates a [ViewCircuitDetailsUseCase] with the given [circuitRepository].
  ViewCircuitDetailsUseCase({required this.circuitRepository});

  /// Retrieves the current details of the circuit with the given [handle].
  TaskEither<Failure, CircuitWithHandle> call({required CircuitHandle handle}) {
    return circuitRepository.getByHandle(handle: handle);
  }
}
