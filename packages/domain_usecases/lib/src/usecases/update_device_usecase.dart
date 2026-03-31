import 'package:electrical_junctions_contracts/index.dart';

import 'package:fpdart/fpdart.dart';

/// Updates an existing device in the repository.
///
/// Following the UseCase standard, this accepts:
/// - A full Device object representing the desired state after update
/// - A handle to identify which record to update
class UpdateDeviceUseCase {
  final DeviceRepository deviceRepository;

  UpdateDeviceUseCase({required this.deviceRepository});

  /// Updates the provided [device]. Returns the updated device with handle on success.
  TaskEither<Failure, DeviceWithHandle> call({
    required Device device,
    required DeviceHandle handle,
  }) {
    return deviceRepository.update(item: device, handle: handle);
  }
}
