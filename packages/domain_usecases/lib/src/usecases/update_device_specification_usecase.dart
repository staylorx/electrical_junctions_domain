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
  }) {
    return deviceSpecificationRepository.update(item: deviceSpecification);
  }
}
