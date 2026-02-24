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
    required CircuitWithHandle circuit,
  }) {
    if (circuit.circuit.connectedDevices.contains(device)) {
      return TaskEither.left(
        UCValidationFailure('Device is already connected to circuit'),
      );
    }

    final updatedConnected = [...circuit.circuit.connectedDevices, device];
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
