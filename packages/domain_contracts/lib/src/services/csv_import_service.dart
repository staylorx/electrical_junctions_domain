import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';
import '../value_objects/parsing_result.dart';

/// Contract for importing electrical system data from CSV or Excel files.
abstract class CsvImportService {
  /// Imports data from a CSV/Excel file or directory path.
  /// Returns a [ParsingResult] containing parsed entities and any parsing issues.
  TaskEither<Failure, ParsingResult> importFromPath(String path);
}