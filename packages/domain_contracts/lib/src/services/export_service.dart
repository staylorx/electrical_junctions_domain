import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';

/// Abstract service for exporting domain entities to various formats.
///
/// This abstraction allows the domain layer to depend on export functionality
/// without knowing the specific implementation details.
abstract class ExportService {
  /// Exports the provided entities to the specified format.
  ///
  /// Returns a [TaskEither] containing an [ExportResult] on success,
  /// or a [Failure] on error.
  ///
  /// For string-based formats (yaml, markdown, mermaid): ExportResult contains string content.
  /// For binary formats (csv, excel): ExportResult contains appropriate content.
  TaskEither<Failure, ExportResult> export({
    required List<Manufacturer> manufacturers,
    required List<Locate> locates,
    required List<Device> devices,
    required List<DeviceSpecification> deviceSpecifications,
    required List<Circuit> circuits,
    required ExportFormat format,
    ExportMode mode = ExportMode.denormalized,
  });
}
