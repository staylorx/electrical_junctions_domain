import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';

/// Domain service contract for device specification schema operations.
///
/// Manages device type schemas, providing:
/// - Schema registration and retrieval
/// - Property validation for device specifications
/// - Type-safe property accessors
///
/// Schemas define the structure and properties for each device type
/// (e.g., Panel has ampRating, poleCount; CircuitBreaker has tripCurve).
abstract class IDeviceSpecificationSchemaService {
  /// Checks if a device type is registered
  bool isTypeRegistered(String typeName);

  /// Gets the schema for a device type
  DeviceSpecificationSchema? getSchema(String typeId);

  /// Gets a property accessor for a type and property key (functional version)
  Either<Failure, PropertyAccessor<dynamic>> getPropertyAccessorFP(
    String typeId,
    String key,
  );

  /// Validates properties for a type (functional version)
  Either<Failure, Unit> validatePropertiesFP(
    String typeId,
    Map<String, dynamic> properties,
  );

  /// Registers a type definition and creates its schema
  Either<Failure, Unit> registerTypeDefinition(DeviceTypeDefinition definition);
}
