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
    required Circuit circuit,
    required Device device1,
    required Device device2,
    required Device newDevice,
  }) {
    final fullPath = [circuit.sourceDevice, ...circuit.connectedDevices];
    final index1 = fullPath.indexOf(device1);
    final index2 = fullPath.indexOf(device2);

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
    final updatedConnected = List<Device>.from(circuit.connectedDevices);

    if (insertIndex == 1) {
      updatedConnected.insert(0, newDevice);
    } else {
      updatedConnected.insert(insertIndex - 1, newDevice);
    }
    final updatedCircuit = Circuit(
      handle: circuit.handle,
      sourceDevice: circuit.sourceDevice,
      connectedDevices: updatedConnected,
    );
    return updateCircuitUseCase.call(circuit: updatedCircuit).map((_) => unit);
  }
}
