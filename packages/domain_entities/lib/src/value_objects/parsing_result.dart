import 'package:electrical_junctions_entities/index.dart';

/// Result of parsing an import file or directory.
/// Contains the parsed entities and any issues encountered during parsing.
class ParsingResult {
  final ImportModel model;
  final List<ValidationIssue> issues;

  const ParsingResult({required this.model, required this.issues});

  bool get hasErrors => issues.any((i) => i.isError);
}
