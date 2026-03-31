import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the `DisconnectDeviceFromCircuitUseCase` class.
///
/// Following the UseCase standard, accepts handles for related entities
/// and fetches the full Device if needed.
class DisconnectDeviceFromCircuitUseCase {
  final UpdateCircuitUseCase updateCircuitUseCase;
  final DeviceRepository deviceRepository;

  DisconnectDeviceFromCircuitUseCase({
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
      final deviceIndex = circuit.circuit.connectedDevices.indexOf(device);

      if (deviceIndex == -1) {
        return TaskEither.left(
          UCValidationFailure('Device is not connected to circuit'),
        );
      }

      final updatedConnected = List<Device>.from(
        circuit.circuit.connectedDevices,
      )..removeAt(deviceIndex);
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
