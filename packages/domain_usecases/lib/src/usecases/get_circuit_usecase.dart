import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Retrieves details for a `Circuit` by providing the circuit instance.
class GetCircuitUseCase {
  final CircuitRepository circuitRepository;

  GetCircuitUseCase({required this.circuitRepository});

  TaskEither<Failure, Circuit> call({required Circuit circuit}) {
    return circuitRepository
        .getByHandle(handle: circuit.handle)
        .map((fetched) => fetched);
  }
}
