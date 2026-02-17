import 'package:electrical_junctions_contracts/index.dart';

import 'package:fpdart/fpdart.dart';

/// Deletes a `DeviceSpecification` from the repository.
class DeleteDeviceSpecificationUseCase {
  final DeviceSpecificationRepository deviceSpecificationRepository;

  DeleteDeviceSpecificationUseCase({
    required this.deviceSpecificationRepository,
  });

  TaskEither<Failure, Unit> call({required DeviceSpecificationHandle handle}) {
    return deviceSpecificationRepository.delete(handle: handle);
  }
}
