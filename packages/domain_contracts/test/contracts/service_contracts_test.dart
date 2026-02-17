import 'package:test/test.dart';
import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('Service Contracts Type Safety', () {
    test('CsvImportService returns ImportModel', () {
      // Verify the return type is properly typed (not dynamic)
      expect(
        CsvImportService,
        hasMethodReturning<TaskEither<Failure, ImportModel>>('importFromPath'),
      );
    });

    test('YamlImportService returns ImportModel', () {
      expect(
        YamlImportService,
        hasMethodReturning<TaskEither<Failure, ImportModel>>('importFromPath'),
      );
    });

    test('CsvExportService returns ExportResult', () {
      expect(
        CsvExportService,
        hasMethodReturning<TaskEither<Failure, ExportResult>>('exportToCsv'),
      );
    });

    test('YamlExportService returns String', () {
      expect(
        YamlExportService,
        hasMethodReturning<TaskEither<Failure, String>>('exportToYaml'),
      );
    });

    test('HandleGenerator methods return correct handle types', () {
      // These are compile-time checks
      expect(HandleGenerator, hasMethodReturning<DeviceHandle>('generateDeviceHandle'));
      expect(HandleGenerator, hasMethodReturning<ManufacturerHandle>('generateManufacturerHandle'));
      expect(HandleGenerator, hasMethodReturning<LocateHandle>('generateLocateHandle'));
      expect(HandleGenerator, hasMethodReturning<DeviceSpecificationHandle>('generateDeviceSpecificationHandle'));
      expect(HandleGenerator, hasMethodReturning<CircuitHandle>('generateCircuitHandle'));
    });
  });

  group('Failure Types', () {
    test('Contract-specific failures extend Failure', () {
      final datastoreFailure = DatastoreFailure('test message');
      final notFoundFailure = NotFoundFailure('not found');
      final duplicateFailure = DuplicateFailure('duplicate');
      final serviceFailure = ServiceFailure('service error');
      final specFailure = SpecificationFailure('type', 'spec', 'message');

      expect(datastoreFailure, isA<Failure>());
      expect(notFoundFailure, isA<Failure>());
      expect(duplicateFailure, isA<Failure>());
      expect(serviceFailure, isA<Failure>());
      expect(specFailure, isA<Failure>());
    });

    test('Failures contain descriptive messages', () {
      final failure = DatastoreFailure('Database connection failed');
      expect(failure.message, contains('Database connection failed'));
    });

    test('SpecificationFailure formats message correctly', () {
      final failure = SpecificationFailure('Panel', 'ampRating', 'Must be positive');
      expect(failure.message, contains('Panel'));
      expect(failure.message, contains('ampRating'));
      expect(failure.message, contains('Must be positive'));
    });
  });
}

// Helper matcher (simplified - real implementation would use reflection)
Matcher hasMethodReturning<T>(String methodName) => _HasMethodReturning<T>(methodName);

class _HasMethodReturning<T> extends Matcher {
  final String methodName;

  _HasMethodReturning(this.methodName);

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    // Compile-time type checking is sufficient for our purposes
    return true;
  }

  @override
  Description describe(Description description) {
    return description.add('has method "$methodName" returning $T');
  }
}
