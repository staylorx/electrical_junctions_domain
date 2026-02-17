import 'package:electrical_junctions_contracts/index.dart';

import 'package:fpdart/fpdart.dart';

/// Deletes a device from the repository.
class DeleteDeviceUseCase {
  final DeviceRepository deviceRepository;

  DeleteDeviceUseCase({required this.deviceRepository});

  /// Deletes the provided [device]. Returns unit on success.
  TaskEither<Failure, Unit> call({required DeviceHandle handle}) {
    return deviceRepository.delete(handle: handle);
  }
}
