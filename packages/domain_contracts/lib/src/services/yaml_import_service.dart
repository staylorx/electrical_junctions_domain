import 'package:fpdart/fpdart.dart';
import 'package:electrical_junctions_entities/index.dart';
import '../value_objects/parsing_result.dart';

/// Contract for importing electrical system data from YAML files.
abstract class YamlImportService {
  /// Imports data from a YAML file or directory path.
  /// Returns a [ParsingResult] containing parsed entities and any parsing issues.
  TaskEither<Failure, ParsingResult> importFromPath(String path);
}