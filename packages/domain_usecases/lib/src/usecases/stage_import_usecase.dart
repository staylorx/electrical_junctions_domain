import 'package:fpdart/fpdart.dart';
import '../../index.dart';

/// Stages parsed import data by validating entities.
///
/// This use case takes a [ParsingResult] from an import service, validates
/// the entities, and returns an [ImportResult] with any issues collected
/// during validation and the staged import data.
class StageImportUseCase {
  final ImportValidator _entityValidator;

  StageImportUseCase({required ImportValidator entityValidator})
    : _entityValidator = entityValidator;

  /// Stages the parsed import data.
  ///
  /// Validates the entities in the model and returns an [ImportResult]
  /// with collected issues and the staged import data.
  TaskEither<Failure, ImportResult> call(ParsingResult parsingResult) {
    return TaskEither(() async {
      final issues = <ValidationIssue>[...parsingResult.issues];

      // Validate entities
      final validationResult = _entityValidator.validate(parsingResult.model);
      if (!validationResult.isValid) {
        for (final error in validationResult.errors) {
          issues.add(
            ValidationIssue(
              severity: ValidationSeverity.error,
              message: error.toString(),
            ),
          );
        }
      }
      for (final warning in validationResult.warnings) {
        issues.add(
          ValidationIssue(
            severity: ValidationSeverity.warning,
            message: warning.toString(),
          ),
        );
      }

      // Create staged import from validated model
      final stagedImport = ImportModel(
        manufacturers: parsingResult.model.manufacturers,
        locates: parsingResult.model.locates,
        deviceSpecifications: parsingResult.model.deviceSpecifications,
        devices: parsingResult.model.devices,
        circuits: parsingResult.model.circuits,
      );

      // Build summary
      final summary = _buildSummary(parsingResult.model);

      return Right(
        ImportResult(
          issues: issues,
          summary: summary,
          importModel: stagedImport,
        ),
      );
    });
  }

  String _buildSummary(ImportModel model) {
    return 'Staged ${model.manufacturers.length} manufacturers, '
        '${model.locates.length} locates, '
        '${model.deviceSpecifications.length} device specifications, '
        '${model.devices.length} devices, '
        '${model.circuits.length} circuits.';
  }
}
