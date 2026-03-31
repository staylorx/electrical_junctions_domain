import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Creates or saves a `Circuit` using the repository `create` method.
///
/// Following the UseCase standard, this accepts:
/// - Handles for related persisted device entities (sourceDeviceHandle, connectedDeviceHandles)
/// - Simple parameters for the circuit itself (name, stereotype)
class CreateCircuitUseCase {
  final CircuitRepository circuitRepository;
  final DeviceRepository deviceRepository;

  CreateCircuitUseCase({
    required this.circuitRepository,
    required this.deviceRepository,
  });

  TaskEither<Failure, CircuitWithHandle> call({
    String? name,
    required DeviceHandle sourceDeviceHandle,
    List<DeviceHandle> connectedDeviceHandles = const [],
    String? stereotype,
  }) {
    // Fetch the source device
    return deviceRepository.getByHandle(handle: sourceDeviceHandle).flatMap((
      sourceDeviceWithHandle,
    ) {
      // Fetch all connected devices if any
      if (connectedDeviceHandles.isEmpty) {
        final circuit = Circuit(
          name: name,
          sourceDevice: sourceDeviceWithHandle.device,
          connectedDevices: [],
          stereotype: stereotype,
        );
        return circuitRepository.create(item: circuit);
      }

      return _fetchConnectedDevices(connectedDeviceHandles).flatMap((
        connectedDevices,
      ) {
        final circuit = Circuit(
          name: name,
          sourceDevice: sourceDeviceWithHandle.device,
          connectedDevices: connectedDevices,
          stereotype: stereotype,
        );
        return circuitRepository.create(item: circuit);
      });
    });
  }

  /// Fetch all connected devices by their handles
  TaskEither<Failure, List<Device>> _fetchConnectedDevices(
    List<DeviceHandle> handles,
  ) {
    if (handles.isEmpty) {
      return TaskEither.right([]);
    }

    // Fetch all devices in sequence
    return TaskEither.tryCatch(
      () async {
        final devices = <Device>[];
        for (final handle in handles) {
          final result = await deviceRepository
              .getByHandle(handle: handle)
              .run();
          final device = result.fold(
            (failure) => throw failure,
            (deviceWithHandle) => deviceWithHandle.device,
          );
          devices.add(device);
        }
        return devices;
      },
      (error, stackTrace) => error is Failure
          ? error
          : DatastoreFailure('Failed to fetch connected devices: $error'),
    );
  }
}
