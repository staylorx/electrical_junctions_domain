import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Updates a `Circuit` by using the repository `update` method.
class UpdateCircuitUseCase {
  final CircuitRepository circuitRepository;

  UpdateCircuitUseCase({required this.circuitRepository});

  TaskEither<Failure, Circuit> call({
    required Circuit circuit,
    required CircuitHandle handle,
  }) {
    return circuitRepository
        .update(item: circuit, handle: handle)
        .mapLeft((failure) => failure)
        .map((updated) => updated.circuit);
  }
}
