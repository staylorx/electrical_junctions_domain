import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';

/// Abstract service for exporting domain entities to a string format.
///
/// This abstraction allows the domain layer to depend on export functionality
/// without knowing the specific format (e.g., YAML, JSON).
abstract class YamlExportService {
  /// Exports the provided entities to a string representation.
  ///
  /// Returns a [TaskEither] containing the exported string on success,
  /// or a [Failure] on error.
  TaskEither<Failure, String> exportToYaml({
    required List<Manufacturer> manufacturers,
    required List<Locate> locates,
    required List<Device> devices,
    required List<DeviceSpecification> deviceSpecifications,
    required List<Circuit> circuits,
  });
}
