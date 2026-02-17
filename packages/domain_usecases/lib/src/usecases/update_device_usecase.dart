import 'package:electrical_junctions_contracts/index.dart';

import 'package:fpdart/fpdart.dart';

/// Updates an existing device in the repository.
class UpdateDeviceUseCase {
  final DeviceRepository deviceRepository;

  UpdateDeviceUseCase({required this.deviceRepository});

  /// Updates the provided [device]. Returns the updated device on success.
  TaskEither<Failure, Device> call({
    String? name,
    required DeviceSpecification deviceSpecification,
    Locate? locate,
    required DeviceHandle handle,
  }) {
    final result = deviceRepository.getByHandle(handle: handle).flatMap((
      existingDevice,
    ) {
      final updatedDevice = existingDevice.copyWith(
        name: name,
        deviceSpecification: deviceSpecification,
        locate: locate,
      );
      return deviceRepository.update(item: updatedDevice);
    });
    return result;
  }
}
