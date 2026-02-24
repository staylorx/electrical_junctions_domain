import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Creates a new `DeviceSpecification` and saves it to the repository.
class CreateDeviceSpecificationUseCase {
  final DeviceSpecificationRepository deviceSpecificationRepository;

  CreateDeviceSpecificationUseCase({
    required this.deviceSpecificationRepository,
  });

  TaskEither<Failure, DeviceSpecification> call({
    required String typeId,
    required String modelNumber,
    required Manufacturer manufacturer,
    Map<String, dynamic> properties = const {},
  }) {
    final deviceSpecification = DeviceSpecification(
      typeId: typeId,
      modelNumber: modelNumber,
      manufacturer: manufacturer,
      properties: properties,
    );
    return deviceSpecificationRepository
        .create(item: deviceSpecification)
        .map((_) => deviceSpecification);
  }
}
