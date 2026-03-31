import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Creates a new `DeviceSpecification` and saves it to the repository.
///
/// Following the UseCase standard, this accepts:
/// - Simple business parameters for the specification (typeId, modelNumber, properties)
/// - A handle for the related persisted manufacturer entity
class CreateDeviceSpecificationUseCase {
  final DeviceSpecificationRepository deviceSpecificationRepository;
  final ManufacturerRepository manufacturerRepository;

  CreateDeviceSpecificationUseCase({
    required this.deviceSpecificationRepository,
    required this.manufacturerRepository,
  });

  TaskEither<Failure, DeviceSpecificationWithHandle> call({
    required String typeId,
    required String modelNumber,
    required ManufacturerHandle manufacturerHandle,
    Map<String, dynamic> properties = const {},
  }) {
    // Fetch the manufacturer and then create the device specification
    return manufacturerRepository
        .getByHandle(handle: manufacturerHandle)
        .flatMap((manufacturerWithHandle) {
          final deviceSpecification = DeviceSpecification(
            typeId: typeId,
            modelNumber: modelNumber,
            manufacturer: manufacturerWithHandle.manufacturer,
            properties: properties,
          );
          return deviceSpecificationRepository.create(
            item: deviceSpecification,
          );
        });
  }
}
