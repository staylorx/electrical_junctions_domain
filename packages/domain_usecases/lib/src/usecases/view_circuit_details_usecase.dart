import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for viewing the details of a circuit.
class ViewCircuitDetailsUseCase {
  final CircuitRepository circuitRepository;

  /// Creates a [ViewCircuitDetailsUseCase] with the given [circuitRepository].
  ViewCircuitDetailsUseCase({required this.circuitRepository});

  /// Retrieves the current details of the given [circuit].
  TaskEither<Failure, Circuit> call({required Circuit circuit}) {
    return circuitRepository
        .getByHandle(handle: circuit.handle)
        .map((fetched) => fetched);
  }
}
