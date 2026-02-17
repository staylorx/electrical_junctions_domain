import 'package:electrical_junctions_usecases/index.dart';

import 'package:fpdart/fpdart.dart';

/// Retrieves a property value from a DeviceSpecification by handle and property key.
/// Validates the property access using the schema service.
class GetDeviceSpecificationPropertyUseCase {
  final DeviceSpecificationRepository deviceSpecificationRepository;
  final IDeviceSpecificationSchemaService schemaService;

  GetDeviceSpecificationPropertyUseCase({
    required this.deviceSpecificationRepository,
    required this.schemaService,
  });

  TaskEither<Failure, dynamic> call({
    required DeviceSpecificationHandle handle,
    required String propertyKey,
  }) {
    return deviceSpecificationRepository.getByHandle(handle: handle).flatMap((
      deviceSpec,
    ) {
      return TaskEither.fromEither(
        schemaService
            .getPropertyAccessorFP(deviceSpec.typeId, propertyKey)
            .flatMap((accessor) {
              try {
                final value = accessor.get(deviceSpec.properties);
                return Right(value);
              } catch (e) {
                return Left(
                  InvalidPropertyDefinitionFailure(
                    propertyKey,
                    'Failed to get property: $e',
                  ),
                );
              }
            }),
      );
    });
  }
}
