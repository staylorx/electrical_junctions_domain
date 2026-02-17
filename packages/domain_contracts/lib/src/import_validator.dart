import 'package:electrical_junctions_entities/index.dart';

/// Contract for validating import models.
///
/// Implementations validate imported data for correctness and consistency
/// before it's persisted to the repository.
///
/// Example implementations:
/// - YamlImportValidator: Validates YAML import data
/// - CsvImportValidator: Validates CSV import data
abstract class ImportValidator {
  /// Validates the given import model.
  /// Returns a [ValidationResult] with any issues found.
  /// [model] is dynamic to support different import model types.
  ValidationResult validate(dynamic model);
}
