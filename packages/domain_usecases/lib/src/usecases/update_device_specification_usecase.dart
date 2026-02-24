import 'package:electrical_junctions_contracts/index.dart';

import 'package:fpdart/fpdart.dart';

/// Updates an existing `DeviceSpecification` in the repository.
class UpdateDeviceSpecificationUseCase {
  final DeviceSpecificationRepository deviceSpecificationRepository;

  UpdateDeviceSpecificationUseCase({
    required this.deviceSpecificationRepository,
  });

  TaskEither<Failure, DeviceSpecification> call({
    required DeviceSpecification deviceSpecification,
    required DeviceSpecificationHandle handle,
  }) {
    return deviceSpecificationRepository
        .update(item: deviceSpecification, handle: handle)
        .mapLeft((failure) => failure)
        .map((updated) => updated.deviceSpecification);
  }
}
