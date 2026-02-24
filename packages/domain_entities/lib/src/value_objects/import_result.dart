import 'package:electrical_junctions_entities/index.dart';

/// Carries the outcome of a two-phase staged import operation.
///
/// [issues] contains every validation or save issue collected during the import
/// (both file-level and entity-level).  [summary] is a human-readable
/// entity-count string. [importModel] contains the successfully imported entities.
///
/// The import only returns [Left] for truly unrecoverable problems (path not
/// found, completely unparseable data).  Everything else is surfaced here.
class ImportResult {
  /// All issues collected during the import pipeline.
  final List<ValidationIssue> issues;

  /// Human-readable summary of entity counts.
  final String summary;

  /// The successfully staged import data.
  final ImportModel importModel;

  const ImportResult({
    required this.issues,
    required this.summary,
    required this.importModel,
  });

  /// True if any collected issue is an error.
  bool get hasErrors => issues.any((i) => i.isError);

  /// Only the error-severity issues.
  List<ValidationIssue> get errors => issues.where((i) => i.isError).toList();

  /// Only the warning-severity issues.
  List<ValidationIssue> get warnings =>
      issues.where((i) => i.isWarning).toList();

  /// Whether the collected issues satisfy the given [criteria].
  /// Defaults to [ImportPassCriteria.noErrors].
  bool passes({ImportPassCriteria? criteria}) =>
      (criteria ?? ImportPassCriteria.noErrors).passes(issues);
}
