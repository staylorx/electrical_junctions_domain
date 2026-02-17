import 'package:fpdart/fpdart.dart';
import '../../index.dart';

/// Determines how staged entities are written to the target database.
enum CommitMode {
  /// Clears the target database first, then writes all staged entities.
  overwrite,

  /// Upserts staged entities by ID.  Entities already in the target that are
  /// NOT in the staged import are left untouched.
  merge,
}

/// Copies a successfully staged import into a target production database.
///
/// Usage:
/// ```dart
/// final targetFacade = ElectricalJunctionsFacade(databaseService: productionDb);
/// final commit = CommitImportUseCase(targetFacade: targetFacade);
/// final result = await commit.call(
///   importResult: importResult,
///   mode: CommitMode.overwrite,
/// ).run();
/// ```
class CommitImportUseCase {
  final StagingFacade _targetFacade;

  CommitImportUseCase({required StagingFacade targetFacade})
    : _targetFacade = targetFacade;

  /// Commits [importResult] to the target database.
  ///
  /// Returns [Left] if [importResult] does not pass [criteria] (defaults to
  /// [ImportPassCriteria.noErrors]), or if any write operation fails.
  /// Returns [Right] with a summary string on success.
  TaskEither<Failure, String> call({
    required ImportResult importResult,
    CommitMode mode = CommitMode.overwrite,
    ImportPassCriteria? criteria,
  }) {
    return TaskEither(() async {
      // Gate: verify the import passes the threshold before committing.
      if (!importResult.passes(criteria: criteria)) {
        final effectiveCriteria = criteria ?? ImportPassCriteria.noErrors;
        return Left(
          UCValidationFailure(
            'Import does not pass criteria '
            '(maxErrors=${effectiveCriteria.maxErrors}, '
            'allowWarnings=${effectiveCriteria.allowWarnings}). '
            'Errors: ${importResult.errors.length}, '
            'Warnings: ${importResult.warnings.length}.',
          ),
        );
      }

      final stagingRepos = importResult.stagingFacade.repositories;
      final targetRepos = _targetFacade.repositories;

      // Read all staging entities
      final mfgResult = await stagingRepos.manufacturer.getAll().run();
      if (mfgResult.isLeft()) {
        return Left(
          UCDatabaseReadFailure('Failed to read staged manufacturers'),
        );
      }
      final manufacturers = mfgResult.getRight().toNullable()!;

      final locResult = await stagingRepos.locate.findAll().run();
      if (locResult.isLeft()) {
        return Left(UCDatabaseReadFailure('Failed to read staged locates'));
      }
      final locates = locResult.getRight().toNullable()!;

      final specResult = await stagingRepos.deviceSpecification.getAll().run();
      if (specResult.isLeft()) {
        return Left(
          UCDatabaseReadFailure('Failed to read staged device specifications'),
        );
      }
      final deviceSpecs = specResult.getRight().toNullable()!;

      final devResult = await stagingRepos.device.getAll().run();
      if (devResult.isLeft()) {
        return Left(UCDatabaseReadFailure('Failed to read staged devices'));
      }
      final devices = devResult.getRight().toNullable()!;

      final circResult = await stagingRepos.circuit.getAll().run();
      if (circResult.isLeft()) {
        return Left(UCDatabaseReadFailure('Failed to read staged circuits'));
      }
      final circuits = circResult.getRight().toNullable()!;

      // -- Clear target if overwrite mode --
      if (mode == CommitMode.overwrite) {
        await _targetFacade.clearAll();
      }

      // -- Write in order: manufacturers → locates → device specs → devices → circuits --

      // Manufacturers
      for (final mfg in manufacturers) {
        final r = await targetRepos.manufacturer.create(item: mfg).run();
        if (r.isLeft()) {
          return Left(
            UCDatabaseWriteFailure(
              'Failed to commit manufacturer: ${mfg.name}',
            ),
          );
        }
      }

      // Locates (must be written root-first; staging DB preserves insertion order)
      for (final loc in locates) {
        final r = await targetRepos.locate.create(item: loc).run();
        if (r.isLeft()) {
          return Left(
            UCDatabaseWriteFailure('Failed to commit locate: ${loc.name}'),
          );
        }
      }

      // Device specifications
      for (final spec in deviceSpecs) {
        final r = await targetRepos.deviceSpecification
            .create(item: spec)
            .run();
        if (r.isLeft()) {
          return Left(
            UCDatabaseWriteFailure(
              'Failed to commit device specification: ${spec.modelNumber}',
            ),
          );
        }
      }

      // Devices
      for (final dev in devices) {
        final r = await targetRepos.device.create(item: dev).run();
        if (r.isLeft()) {
          return Left(
            UCDatabaseWriteFailure('Failed to commit device: ${dev.name}'),
          );
        }
      }

      // Circuits
      for (final circ in circuits) {
        final r = await targetRepos.circuit.create(item: circ).run();
        if (r.isLeft()) {
          return Left(
            UCDatabaseWriteFailure('Failed to commit circuit: ${circ.name}'),
          );
        }
      }

      return Right(
        'Committed ${manufacturers.length} manufacturers, '
        '${locates.length} locates, ${deviceSpecs.length} device specifications, '
        '${devices.length} devices, ${circuits.length} circuits.',
      );
    });
  }
}
