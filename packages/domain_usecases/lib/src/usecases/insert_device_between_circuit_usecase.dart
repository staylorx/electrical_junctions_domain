import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the `InsertDeviceBetweenCircuitUseCase` class.
///
/// Following the UseCase standard, accepts handles for device references
/// and fetches the full Device objects if needed.
class InsertDeviceBetweenCircuitUseCase {
  final UpdateCircuitUseCase updateCircuitUseCase;
  final DeviceRepository deviceRepository;

  InsertDeviceBetweenCircuitUseCase({
    UpdateCircuitUseCase? updateCircuitUseCase,
    CircuitRepository? circuitRepository,
    DeviceRepository? deviceRepository,
  }) : updateCircuitUseCase =
           updateCircuitUseCase ??
           UpdateCircuitUseCase(circuitRepository: circuitRepository!),
       deviceRepository = deviceRepository!;

  TaskEither<Failure, Unit> call({
    required CircuitWithHandle circuit,
    required DeviceHandle device1Handle,
    required DeviceHandle device2Handle,
    required DeviceHandle newDeviceHandle,
  }) {
    return deviceRepository.getByHandle(handle: device1Handle).flatMap((
      device1With,
    ) {
      return deviceRepository.getByHandle(handle: device2Handle).flatMap((
        device2With,
      ) {
        return deviceRepository.getByHandle(handle: newDeviceHandle).flatMap((
          newDeviceWith,
        ) {
          final device1 = device1With.device;
          final device2 = device2With.device;
          final newDevice = newDeviceWith.device;

          final fullPath = [
            circuit.circuit.sourceDevice,
            ...circuit.circuit.connectedDevices,
          ];
          final index1 = fullPath.indexWhere((e) => identical(e, device1));
          final index2 = fullPath.indexWhere((e) => identical(e, device2));

          if (index1 == -1 || index2 == -1) {
            return TaskEither.left(
              UCValidationFailure(
                'One or both devices not found in circuit path',
              ),
            );
          }

          if ((index1 - index2).abs() != 1) {
            return TaskEither.left(
              UCValidationFailure(
                'Devices are not consecutive in circuit path',
              ),
            );
          }
          final insertIndex = index1 < index2 ? index1 + 1 : index2 + 1;
          final updatedConnected = List<Device>.from(
            circuit.circuit.connectedDevices,
          );

          if (insertIndex == 1) {
            updatedConnected.insert(0, newDevice);
          } else {
            updatedConnected.insert(insertIndex - 1, newDevice);
          }
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
      });
    });
  }
}
