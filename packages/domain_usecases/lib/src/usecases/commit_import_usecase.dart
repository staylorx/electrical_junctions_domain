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
class CommitImportUseCase {
  final ManufacturerRepository _manufacturerRepository;
  final LocateRepository _locateRepository;
  final DeviceSpecificationRepository _deviceSpecificationRepository;
  final DeviceRepository _deviceRepository;
  final CircuitRepository _circuitRepository;

  CommitImportUseCase({
    required ManufacturerRepository manufacturerRepository,
    required LocateRepository locateRepository,
    required DeviceSpecificationRepository deviceSpecificationRepository,
    required DeviceRepository deviceRepository,
    required CircuitRepository circuitRepository,
  }) : _manufacturerRepository = manufacturerRepository,
       _locateRepository = locateRepository,
       _deviceSpecificationRepository = deviceSpecificationRepository,
       _deviceRepository = deviceRepository,
       _circuitRepository = circuitRepository;

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

      // Get staged entities directly from import result
      final manufacturers = importResult.importModel.manufacturers;
      final locates = importResult.importModel.locates;
      final deviceSpecs = importResult.importModel.deviceSpecifications;
      final devices = importResult.importModel.devices;
      final circuits = importResult.importModel.circuits;

      // -- Clear target if overwrite mode --
      if (mode == CommitMode.overwrite) {
        // Clear all data in reverse dependency order to avoid constraint issues
        final clearCircuits = await _circuitRepository.deleteAll().run();
        if (clearCircuits.isLeft()) {
          return Left(
            UCDatabaseWriteFailure('Failed to clear circuits during overwrite'),
          );
        }

        final clearDevices = await _deviceRepository.deleteAll().run();
        if (clearDevices.isLeft()) {
          return Left(
            UCDatabaseWriteFailure('Failed to clear devices during overwrite'),
          );
        }

        final clearDeviceSpecs = await _deviceSpecificationRepository
            .deleteAll()
            .run();
        if (clearDeviceSpecs.isLeft()) {
          return Left(
            UCDatabaseWriteFailure(
              'Failed to clear device specifications during overwrite',
            ),
          );
        }

        final clearLocates = await _locateRepository.deleteAll().run();
        if (clearLocates.isLeft()) {
          return Left(
            UCDatabaseWriteFailure('Failed to clear locates during overwrite'),
          );
        }

        final clearManufacturers = await _manufacturerRepository
            .deleteAll()
            .run();
        if (clearManufacturers.isLeft()) {
          return Left(
            UCDatabaseWriteFailure(
              'Failed to clear manufacturers during overwrite',
            ),
          );
        }
      }

      // -- Write in order: manufacturers → locates → device specs → devices → circuits --

      // Manufacturers
      for (final mfg in manufacturers) {
        final r = await _manufacturerRepository.create(item: mfg).run();
        if (r.isLeft()) {
          return Left(
            UCDatabaseWriteFailure(
              'Failed to commit manufacturer: ${mfg.name}',
            ),
          );
        }
      }

      // Locates (must be written root-first; staging preserves insertion order)
      for (final loc in locates) {
        final r = await _locateRepository.create(item: loc).run();
        if (r.isLeft()) {
          return Left(
            UCDatabaseWriteFailure('Failed to commit locate: ${loc.name}'),
          );
        }
      }

      // Device specifications
      for (final spec in deviceSpecs) {
        final r = await _deviceSpecificationRepository.create(item: spec).run();
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
        final r = await _deviceRepository.create(item: dev).run();
        if (r.isLeft()) {
          return Left(
            UCDatabaseWriteFailure('Failed to commit device: ${dev.name}'),
          );
        }
      }

      // Circuits
      for (final circ in circuits) {
        final r = await _circuitRepository.create(item: circ).run();
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
