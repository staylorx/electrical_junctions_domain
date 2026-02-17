import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';

/// Abstract interface for loading file content.
/// Implementations handle the actual I/O operations.
abstract class FileLoader {
  /// Loads the content of a file at the given path.
  TaskEither<Failure, String> loadFile(String path);

  /// Scans a directory and returns paths to all matching files.
  TaskEither<Failure, List<String>> scanDirectory(
    String path, {
    String extension = '',
  });
}
