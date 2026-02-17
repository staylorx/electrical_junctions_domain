import 'validation_severity.dart';

/// Represents a single validation issue
class ValidationIssue {
  final ValidationSeverity severity;
  final String message;
  final String?
  path; // YAML path where issue occurred (e.g., "devices[0].name")
  final String? context; // Additional context

  const ValidationIssue({
    required this.severity,
    required this.message,
    this.path,
    this.context,
  });

  bool get isError => severity == ValidationSeverity.error;
  bool get isWarning => severity == ValidationSeverity.warning;

  @override
  String toString() {
    final prefix = severity == ValidationSeverity.error ? 'ERROR' : 'WARNING';
    final location = path != null ? ' at $path' : '';
    return '$prefix$location: $message${context != null ? ' ($context)' : ''}';
  }
}
