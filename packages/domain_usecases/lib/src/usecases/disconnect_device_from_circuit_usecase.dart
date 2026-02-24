import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the `DisconnectDeviceFromCircuitUseCase` class.
class DisconnectDeviceFromCircuitUseCase {
  final UpdateCircuitUseCase updateCircuitUseCase;

  DisconnectDeviceFromCircuitUseCase({
    UpdateCircuitUseCase? updateCircuitUseCase,
    CircuitRepository? circuitRepository,
  }) : updateCircuitUseCase =
           updateCircuitUseCase ??
           UpdateCircuitUseCase(circuitRepository: circuitRepository!);
  TaskEither<Failure, Unit> call({
    required Device device,
    required CircuitWithHandle circuit,
  }) {
    final deviceIndex = circuit.circuit.connectedDevices.indexOf(device);

    if (deviceIndex == -1) {
      return TaskEither.left(
        UCValidationFailure('Device is not connected to circuit'),
      );
    }

    final updatedConnected = List<Device>.from(circuit.circuit.connectedDevices)
      ..removeAt(deviceIndex);
    final updatedCircuitEntity = Circuit(
      name: circuit.circuit.name,
      sourceDevice: circuit.circuit.sourceDevice,
      connectedDevices: updatedConnected,
      stereotype: circuit.circuit.stereotype,
    );
    final updatedCircuitWithHandle = circuit.copyWith(
      circuit: updatedCircuitEntity,
    );
    return updateCircuitUseCase
        .call(
          circuit: updatedCircuitWithHandle.circuit,
          handle: updatedCircuitWithHandle.handle,
        )
        .map((_) => unit);
  }
}
