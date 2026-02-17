import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';

/// Contract for loading device type schemas from YAML configuration.
///
/// Provides infrastructure abstraction for loading schema definitions
/// from YAML files without coupling domain logic to YAML parsing details.
abstract class YamlSchemaLoader {
  /// Loads type definitions from YAML content
  /// Returns TaskEither with failure on left, definitions on right
  TaskEither<Failure, List<DeviceTypeDefinition>> loadFromYaml(
    String yamlContent,
  );

  /// Loads type definitions from a file path
  /// Returns TaskEither with failure on left, definitions on right
  TaskEither<Failure, List<DeviceTypeDefinition>> loadFromFile(String filePath);

  /// Validates YAML schema structure without loading
  /// Returns TaskEither with failure on left, unit on right
  TaskEither<Failure, Unit> validateSchema(String yamlContent);
}