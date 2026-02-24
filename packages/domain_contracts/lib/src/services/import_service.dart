import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';

/// Contract for importing electrical system data from various formats.
abstract class ImportService {
  /// Imports data from raw string content in the specified format.
  /// Returns a [ParsingResult] containing parsed entities and any parsing issues.
  TaskEither<Failure, ParsingResult> importFromString(
    String data,
    ImportFormat format,
  );
}