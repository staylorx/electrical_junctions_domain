import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Retrieves details for a `Circuit` by providing the circuit handle.
class GetCircuitUseCase {
  final CircuitRepository circuitRepository;

  GetCircuitUseCase({required this.circuitRepository});

  TaskEither<Failure, Circuit> call({required CircuitHandle handle}) {
    return circuitRepository
        .getByHandle(handle: handle)
        .mapLeft((failure) => failure)
        .map((fetched) => fetched.circuit);
  }
}
