import 'package:electrical_junctions_entities/index.dart';

/// Service contract for generating unique handles for domain entities.
///
/// Handles are type-safe value objects that uniquely identify entities.
/// This abstraction allows the domain layer to generate handles without
/// depending on infrastructure concerns like UUID generation.
///
/// Typical implementation: UUID-based handle generator.
abstract class HandleGenerator {
  /// Generate a unique handle for a Device entity.
  DeviceHandle generateDeviceHandle();

  /// Generate a unique handle for a Manufacturer entity.
  ManufacturerHandle generateManufacturerHandle();

  /// Generate a unique handle for a Locate entity.
  LocateHandle generateLocateHandle();

  /// Generate a unique handle for a DeviceSpecification entity.
  DeviceSpecificationHandle generateDeviceSpecificationHandle();

  /// Generate a unique handle for a Circuit entity.
  CircuitHandle generateCircuitHandle();
}