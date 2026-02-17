import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the `ConnectDeviceToCircuitUseCase` class.
class ConnectDeviceToCircuitUseCase {
  final UpdateCircuitUseCase updateCircuitUseCase;

  ConnectDeviceToCircuitUseCase({
    UpdateCircuitUseCase? updateCircuitUseCase,
    CircuitRepository? circuitRepository,
  }) : updateCircuitUseCase =
           updateCircuitUseCase ??
           UpdateCircuitUseCase(circuitRepository: circuitRepository!);
  TaskEither<Failure, Unit> call({
    required Device device,
    required Circuit circuit,
  }) {
    if (circuit.connectedDevices.contains(device)) {
      return TaskEither.left(
        UCValidationFailure('Device is already connected to circuit'),
      );
    }

    final updatedConnected = [...circuit.connectedDevices, device];
    final updatedCircuit = Circuit(
      handle: circuit.handle,
      sourceDevice: circuit.sourceDevice,
      connectedDevices: updatedConnected,
    );
    return updateCircuitUseCase.call(circuit: updatedCircuit).map((_) => unit);
  }
}
