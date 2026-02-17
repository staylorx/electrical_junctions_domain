import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Updates a `Circuit` by using the repository `save` method (no explicit update API).
class UpdateCircuitUseCase {
  final CircuitRepository circuitRepository;

  UpdateCircuitUseCase({required this.circuitRepository});

  TaskEither<Failure, Circuit> call({required Circuit circuit}) {
    return circuitRepository.create(item: circuit);
  }
}
