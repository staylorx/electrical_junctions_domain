import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the `ConnectDeviceToCircuitUseCase` class.
///
/// Following the UseCase standard, accepts handles for related entities
/// and fetches the full Device if needed.
class ConnectDeviceToCircuitUseCase {
  final UpdateCircuitUseCase updateCircuitUseCase;
  final DeviceRepository deviceRepository;

  ConnectDeviceToCircuitUseCase({
    UpdateCircuitUseCase? updateCircuitUseCase,
    CircuitRepository? circuitRepository,
    DeviceRepository? deviceRepository,
  }) : updateCircuitUseCase =
           updateCircuitUseCase ??
           UpdateCircuitUseCase(circuitRepository: circuitRepository!),
       deviceRepository = deviceRepository!;

  TaskEither<Failure, Unit> call({
    required DeviceHandle deviceHandle,
    required CircuitWithHandle circuit,
  }) {
    return deviceRepository.getByHandle(handle: deviceHandle).flatMap((
      deviceWithHandle,
    ) {
      final device = deviceWithHandle.device;

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
      return updateCircuitUseCase
          .call(circuit: updatedCircuitEntity, handle: circuit.handle)
          .map((_) => unit);
    });
  }
}
