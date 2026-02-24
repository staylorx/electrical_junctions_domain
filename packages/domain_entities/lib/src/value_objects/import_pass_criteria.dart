import 'package:electrical_junctions_entities/index.dart';

/// Pluggable strategy for determining whether an import's collected issues
/// meet an acceptable threshold for committing.
class ImportPassCriteria {
  /// Whether warnings are permitted. Defaults to true.
  final bool allowWarnings;

  /// Maximum number of errors permitted. Defaults to 0.
  final int maxErrors;

  const ImportPassCriteria({this.allowWarnings = true, this.maxErrors = 0});

  /// Default criteria: warnings allowed, zero errors tolerated.
  static const ImportPassCriteria noErrors = ImportPassCriteria(
    allowWarnings: true,
    maxErrors: 0,
  );

  /// Strict criteria: no warnings and no errors tolerated.
  static const ImportPassCriteria strict = ImportPassCriteria(
    allowWarnings: false,
    maxErrors: 0,
  );

  /// Returns true if [issues] satisfy this criteria.
  bool passes(List<ValidationIssue> issues) {
    final errorCount = issues.where((i) => i.isError).length;
    if (errorCount > maxErrors) return false;
    if (!allowWarnings && issues.any((i) => i.isWarning)) return false;
    return true;
  }
}
