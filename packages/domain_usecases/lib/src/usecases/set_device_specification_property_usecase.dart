import 'package:electrical_junctions_usecases/index.dart';

import 'package:fpdart/fpdart.dart';

/// Sets a property value on a DeviceSpecification by handle and property key.
/// Validates the property access and value using the schema service.
class SetDeviceSpecificationPropertyUseCase {
  final DeviceSpecificationRepository deviceSpecificationRepository;
  final IDeviceSpecificationSchemaService schemaService;

  SetDeviceSpecificationPropertyUseCase({
    required this.deviceSpecificationRepository,
    required this.schemaService,
  });

  TaskEither<Failure, Unit> call({
    required DeviceSpecificationHandle handle,
    required String propertyKey,
    required dynamic value,
  }) {
    return deviceSpecificationRepository
        .getByHandle(handle: handle)
        .mapLeft((failure) => failure)
        .flatMap((deviceSpec) {
          return TaskEither<Failure, DeviceSpecification>.fromEither(
            schemaService
                .getPropertyAccessorFP(
                  deviceSpec.deviceSpecification.typeId,
                  propertyKey,
                )
                .flatMap((accessor) {
                  try {
                    // Create a copy of properties to modify
                    final updatedProperties = Map<String, dynamic>.from(
                      deviceSpec.deviceSpecification.properties,
                    );
                    accessor.set(updatedProperties, value);

                    // Validate the updated properties
                    return schemaService
                        .validatePropertiesFP(
                          deviceSpec.deviceSpecification.typeId,
                          updatedProperties,
                        )
                        .map((_) {
                          // Create updated device spec
                          final DeviceSpecification updatedDeviceSpec =
                              deviceSpec.deviceSpecification.copyWith(
                                properties: updatedProperties,
                              );
                          return updatedDeviceSpec;
                        });
                  } catch (e) {
                    return Left(
                      InvalidPropertyDefinitionFailure(
                        propertyKey,
                        'Failed to set property: $e',
                      ),
                    );
                  }
                }),
          ).flatMap((updatedDeviceSpec) {
            return deviceSpecificationRepository
                .update(item: updatedDeviceSpec, handle: handle)
                .mapLeft((failure) => failure)
                .map((_) => unit);
          });
        });
  }
}
