import 'package:electrical_junctions_contracts/index.dart';

import 'package:fpdart/fpdart.dart';

/// Retrieves a device by its id from the repository.
class GetDeviceByIdUseCase {
  final DeviceRepository deviceRepository;

  GetDeviceByIdUseCase({required this.deviceRepository});

  /// Returns the device matching [handle] or a Failure if not found.
  TaskEither<Failure, Device> call({required DeviceHandle handle}) {
    return deviceRepository
        .getByHandle(handle: handle)
        .map((deviceWithHandle) => deviceWithHandle.device);
  }
}
