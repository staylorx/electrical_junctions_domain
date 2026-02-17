import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Creates or saves a `Circuit` using the repository `save` method.
class CreateCircuitUseCase {
  final CircuitRepository circuitRepository;
  final HandleGenerator _handleGenerator;

  CreateCircuitUseCase({
    required this.circuitRepository,
    required HandleGenerator handleGenerator,
  }) : _handleGenerator = handleGenerator;

  TaskEither<Failure, Circuit> call({
    required Device sourceDevice,
    List<Device> connectedDevices = const [],
  }) {
    final circuit = Circuit(
      handle: _handleGenerator.generateCircuitHandle(),
      sourceDevice: sourceDevice,
      connectedDevices: connectedDevices,
    );
    return circuitRepository.create(item: circuit);
  }
}
