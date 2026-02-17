import 'validation_issue.dart';
import 'validation_severity.dart';

/// Result of YAML validation containing issues and whether validation passed
class ValidationResult {
  final List<ValidationIssue> issues;

  const ValidationResult(this.issues);

  /// Returns true if there are no errors (warnings are OK)
  bool get isValid => !issues.any((issue) => issue.isError);

  /// Returns only errors
  List<ValidationIssue> get errors =>
      issues.where((issue) => issue.isError).toList();

  /// Returns only warnings
  List<ValidationIssue> get warnings =>
      issues.where((issue) => issue.isWarning).toList();

  /// Combines this result with another
  ValidationResult merge(ValidationResult other) {
    return ValidationResult([...issues, ...other.issues]);
  }

  /// Creates a successful validation result
  static const ValidationResult success = ValidationResult([]);

  /// Creates a result with a single error
  static ValidationResult error(
    String message, {
    String? path,
    String? context,
  }) {
    return ValidationResult([
      ValidationIssue(
        severity: ValidationSeverity.error,
        message: message,
        path: path,
        context: context,
      ),
    ]);
  }

  /// Creates a result with a single warning
  static ValidationResult warning(
    String message, {
    String? path,
    String? context,
  }) {
    return ValidationResult([
      ValidationIssue(
        severity: ValidationSeverity.warning,
        message: message,
        path: path,
        context: context,
      ),
    ]);
  }
}
