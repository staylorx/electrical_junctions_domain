import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';

/// Contract for generating reports using template rendering.
///
/// Implementations use template engines (e.g., Mustache) to generate
/// formatted reports from domain data.
abstract class ReportGeneratorService {
  /// Renders a template with the provided data.
  ///
  /// [template]: The template string (e.g., Mustache template)
  /// [data]: Template variables as key-value pairs
  ///
  /// Returns the rendered string on success, or a [Failure] if rendering fails.
  Either<Failure, String> renderReport(
    String template,
    Map<String, dynamic> data,
  );
}
