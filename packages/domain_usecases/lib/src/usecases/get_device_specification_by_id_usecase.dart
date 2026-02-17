import 'package:electrical_junctions_contracts/index.dart';

import 'package:fpdart/fpdart.dart';

/// Retrieves a `DeviceSpecification` by id from the repository.
class GetDeviceSpecificationByIdUseCase {
  final DeviceSpecificationRepository deviceSpecificationRepository;

  GetDeviceSpecificationByIdUseCase({
    required this.deviceSpecificationRepository,
  });

  TaskEither<Failure, DeviceSpecification> call({
    required DeviceSpecificationHandle handle,
  }) {
    return deviceSpecificationRepository.getByHandle(handle: handle);
  }
}
