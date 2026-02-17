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
    required Circuit circuit,
  }) {
    final deviceIndex = circuit.connectedDevices.indexOf(device);

    if (deviceIndex == -1) {
      return TaskEither.left(
        UCValidationFailure('Device is not connected to circuit'),
      );
    }

    final updatedConnected = List<Device>.from(circuit.connectedDevices)
      ..removeAt(deviceIndex);
    final updatedCircuit = Circuit(
      handle: circuit.handle,
      sourceDevice: circuit.sourceDevice,
      connectedDevices: updatedConnected,
    );
    return updateCircuitUseCase.call(circuit: updatedCircuit).map((_) => unit);
  }
}
