import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Creates or saves a `Circuit` using the repository `save` method.
class CreateCircuitUseCase {
  final CircuitRepository circuitRepository;

  CreateCircuitUseCase({required this.circuitRepository});

  TaskEither<Failure, CircuitWithHandle> call({
    required Device sourceDevice,
    List<Device> connectedDevices = const [],
  }) {
    final circuit = Circuit(
      sourceDevice: sourceDevice,
      connectedDevices: connectedDevices,
    );
    return circuitRepository.create(item: circuit);
  }
}
