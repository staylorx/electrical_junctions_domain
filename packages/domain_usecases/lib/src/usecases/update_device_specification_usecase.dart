import 'package:electrical_junctions_contracts/index.dart';

import 'package:fpdart/fpdart.dart';

/// Updates an existing `DeviceSpecification` in the repository.
///
/// Following the UseCase standard, returns DeviceSpecificationWithHandle to provide
/// the handle for UI layer operations.
class UpdateDeviceSpecificationUseCase {
  final DeviceSpecificationRepository deviceSpecificationRepository;

  UpdateDeviceSpecificationUseCase({
    required this.deviceSpecificationRepository,
  });

  TaskEither<Failure, DeviceSpecificationWithHandle> call({
    required DeviceSpecification deviceSpecification,
    required DeviceSpecificationHandle handle,
  }) {
    return deviceSpecificationRepository.update(
      item: deviceSpecification,
      handle: handle,
    );
  }
}
