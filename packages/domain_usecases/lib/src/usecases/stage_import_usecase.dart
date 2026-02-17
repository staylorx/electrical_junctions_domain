import 'package:fpdart/fpdart.dart';
import '../../index.dart';

/// Stages parsed import data into an in-memory database.
///
/// This use case takes a [ParsingResult] from an import service, validates
/// the entities, saves them to a staging facade, and returns an [ImportResult]
/// with any issues collected during validation and saving.
class StageImportUseCase {
  final ImportValidator _entityValidator;
  final StagingFacadeFactory _stagingFacadeFactory;

  StageImportUseCase({
    required ImportValidator entityValidator,
    required StagingFacadeFactory stagingFacadeFactory,
  }) : _entityValidator = entityValidator,
       _stagingFacadeFactory = stagingFacadeFactory;

  /// Stages the parsed import data.
  ///
  /// Validates the entities in the model, creates a staging facade, saves
  /// the entities, and returns an [ImportResult] with collected issues.
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

      // Create staging facade
      final stagingFacade = _stagingFacadeFactory();

      // Save entities in correct order
      await _saveToStaging(parsingResult.model, stagingFacade, issues);

      // Build summary
      final summary = _buildSummary(parsingResult.model);

      return Right(
        ImportResult(
          issues: issues,
          summary: summary,
          stagingFacade: stagingFacade,
        ),
      );
    });
  }

  Future<void> _saveToStaging(
    ImportModel model,
    StagingFacade facade,
    List<ValidationIssue> issues,
  ) async {
    // Save manufacturers
    for (final mfg in model.manufacturers) {
      final result = await facade.repositories.manufacturer
          .create(item: mfg)
          .run();
      result.match(
        (failure) => issues.add(
          ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'Failed to stage manufacturer: ${mfg.name}',
            context: failure.message,
          ),
        ),
        (_) {},
      );
    }

    // Save locates (assuming order preserves hierarchy)
    for (final loc in model.locates) {
      final result = await facade.repositories.locate.create(item: loc).run();
      result.match(
        (failure) => issues.add(
          ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'Failed to stage locate: ${loc.name}',
            context: failure.message,
          ),
        ),
        (_) {},
      );
    }

    // Save device specifications
    for (final spec in model.deviceSpecifications) {
      final result = await facade.repositories.deviceSpecification
          .create(item: spec)
          .run();
      result.match(
        (failure) => issues.add(
          ValidationIssue(
            severity: ValidationSeverity.error,
            message:
                'Failed to stage device specification: ${spec.modelNumber}',
            context: failure.message,
          ),
        ),
        (_) {},
      );
    }

    // Save devices
    for (final dev in model.devices) {
      final result = await facade.repositories.device.create(item: dev).run();
      result.match(
        (failure) => issues.add(
          ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'Failed to stage device: ${dev.name}',
            context: failure.message,
          ),
        ),
        (_) {},
      );
    }

    // Save circuits
    for (final circ in model.circuits) {
      final result = await facade.repositories.circuit.create(item: circ).run();
      result.match(
        (failure) => issues.add(
          ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'Failed to stage circuit: ${circ.name}',
            context: failure.message,
          ),
        ),
        (_) {},
      );
    }
  }

  String _buildSummary(ImportModel model) {
    return 'Staged ${model.manufacturers.length} manufacturers, '
        '${model.locates.length} locates, '
        '${model.deviceSpecifications.length} device specifications, '
        '${model.devices.length} devices, '
        '${model.circuits.length} circuits.';
  }
}
