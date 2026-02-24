import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for viewing the details of a circuit.
class ViewCircuitDetailsUseCase {
  final CircuitRepository circuitRepository;

  /// Creates a [ViewCircuitDetailsUseCase] with the given [circuitRepository].
  ViewCircuitDetailsUseCase({required this.circuitRepository});

  /// Retrieves the current details of the circuit with the given [handle].
  TaskEither<Failure, Circuit> call({required CircuitHandle handle}) {
    return circuitRepository
        .getByHandle(handle: handle)
        .mapLeft((failure) => failure)
        .map((fetched) => fetched.circuit);
  }
}
