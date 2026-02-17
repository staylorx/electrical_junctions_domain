import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';

/// Abstract service for exporting domain entities to CSV/Excel format.
///
/// This abstraction allows the domain layer to depend on export functionality
/// without knowing the specific implementation details.
abstract class CsvExportService {
  /// Exports the provided entities to CSV or Excel format.
  ///
  /// Returns a [TaskEither] containing an [ExportResult] on success,
  /// or a [Failure] on error.
  ///
  /// For CSV format: ExportResult contains string content.
  /// For Excel format: ExportResult contains bytes content.
  TaskEither<Failure, ExportResult> exportToCsv({
    required List<Manufacturer> manufacturers,
    required List<Locate> locates,
    required List<Device> devices,
    required List<DeviceSpecification> deviceSpecifications,
    required List<Circuit> circuits,
    ExportFormat format = ExportFormat.csv,
    ExportMode mode = ExportMode.denormalized,
  });
}
