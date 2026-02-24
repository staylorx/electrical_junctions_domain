import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the `InsertDeviceBetweenCircuitUseCase` class.
class InsertDeviceBetweenCircuitUseCase {
  final UpdateCircuitUseCase updateCircuitUseCase;

  InsertDeviceBetweenCircuitUseCase({
    UpdateCircuitUseCase? updateCircuitUseCase,
    CircuitRepository? circuitRepository,
  }) : updateCircuitUseCase =
           updateCircuitUseCase ??
           UpdateCircuitUseCase(circuitRepository: circuitRepository!);

  TaskEither<Failure, Unit> call({
    required CircuitWithHandle circuit,
    required Device device1,
    required Device device2,
    required Device newDevice,
  }) {
    final fullPath = [
      circuit.circuit.sourceDevice,
      ...circuit.circuit.connectedDevices,
    ];
    final index1 = fullPath.indexWhere((e) => identical(e, device1));
    final index2 = fullPath.indexWhere((e) => identical(e, device2));

    if (index1 == -1 || index2 == -1) {
      return TaskEither.left(
        UCValidationFailure('One or both devices not found in circuit path'),
      );
    }

    if ((index1 - index2).abs() != 1) {
      return TaskEither.left(
        UCValidationFailure('Devices are not consecutive in circuit path'),
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
