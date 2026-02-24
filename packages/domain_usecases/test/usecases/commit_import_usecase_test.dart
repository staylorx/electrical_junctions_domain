import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockManufacturerRepository extends Mock
    implements ManufacturerRepository {}

class MockLocateRepository extends Mock implements LocateRepository {}

class MockDeviceSpecificationRepository extends Mock
    implements DeviceSpecificationRepository {}

class MockDeviceRepository extends Mock implements DeviceRepository {}

class MockCircuitRepository extends Mock implements CircuitRepository {}

void main() {
  late CommitImportUseCase useCase;
  late MockManufacturerRepository mockManufacturerRepository;
  late MockLocateRepository mockLocateRepository;
  late MockDeviceSpecificationRepository mockDeviceSpecificationRepository;
  late MockDeviceRepository mockDeviceRepository;
  late MockCircuitRepository mockCircuitRepository;

  setUpAll(() {
    registerFallbackValue(Manufacturer(name: 'fallback'));
    registerFallbackValue(Locate(name: 'fallback'));
    registerFallbackValue(
      DeviceSpecification(
        typeId: 'fallback',
        modelNumber: 'fallback',
        manufacturer: Manufacturer(name: 'fallback'),
      ),
    );
    registerFallbackValue(
      Device(
        deviceSpecification: DeviceSpecification(
          typeId: 'fallback',
          modelNumber: 'fallback',
          manufacturer: Manufacturer(name: 'fallback'),
        ),
      ),
    );
    registerFallbackValue(
      Circuit(
        sourceDevice: Device(
          deviceSpecification: DeviceSpecification(
            typeId: 'fallback',
            modelNumber: 'fallback',
            manufacturer: Manufacturer(name: 'fallback'),
          ),
        ),
        connectedDevices: [],
      ),
    );
  });

  setUp(() {
    mockManufacturerRepository = MockManufacturerRepository();
    mockLocateRepository = MockLocateRepository();
    mockDeviceSpecificationRepository = MockDeviceSpecificationRepository();
    mockDeviceRepository = MockDeviceRepository();
    mockCircuitRepository = MockCircuitRepository();
    useCase = CommitImportUseCase(
      manufacturerRepository: mockManufacturerRepository,
      locateRepository: mockLocateRepository,
      deviceSpecificationRepository: mockDeviceSpecificationRepository,
      deviceRepository: mockDeviceRepository,
      circuitRepository: mockCircuitRepository,
    );
  });

  group('Given a CommitImportUseCase', () {
    group('When executing with valid import result', () {
      test('Then it commits all entities and returns success summary', () async {
        // Arrange
        final manufacturer = Manufacturer(name: 'Test Mfg');
        final locate = Locate(name: 'Test Loc');
        final deviceSpec = DeviceSpecification(
          typeId: 'breaker',
          modelNumber: 'QO-20',
          manufacturer: manufacturer,
        );
        final device = Device(deviceSpecification: deviceSpec);
        final circuit = Circuit(sourceDevice: device, connectedDevices: []);
        final importModel = ImportModel(
          manufacturers: [manufacturer],
          locates: [locate],
          deviceSpecifications: [deviceSpec],
          devices: [device],
          circuits: [circuit],
        );
        final importResult = ImportResult(
          issues: [],
          summary: 'Test import',
          importModel: importModel,
        );

        // Setup deleteAll mocks for overwrite mode
        when(
          () => mockCircuitRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockDeviceRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockDeviceSpecificationRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockLocateRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockManufacturerRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));

        when(
          () => mockManufacturerRepository.create(item: any(named: 'item')),
        ).thenReturn(
          TaskEither.right(
            ManufacturerWithHandle(
              handle: ManufacturerHandle('mfg-1'),
              manufacturer: manufacturer,
            ),
          ),
        );
        when(
          () => mockLocateRepository.create(item: any(named: 'item')),
        ).thenReturn(
          TaskEither.right(
            LocateWithHandle(handle: LocateHandle('loc-1'), locate: locate),
          ),
        );
        when(
          () => mockDeviceSpecificationRepository.create(
            item: any(named: 'item'),
          ),
        ).thenReturn(
          TaskEither.right(
            DeviceSpecificationWithHandle(
              handle: DeviceSpecificationHandle('spec-1'),
              deviceSpecification: deviceSpec,
            ),
          ),
        );
        when(
          () => mockDeviceRepository.create(item: any(named: 'item')),
        ).thenReturn(
          TaskEither.right(
            DeviceWithHandle(handle: DeviceHandle('dev-1'), device: device),
          ),
        );
        when(
          () => mockCircuitRepository.create(item: any(named: 'item')),
        ).thenReturn(
          TaskEither.right(
            CircuitWithHandle(
              handle: CircuitHandle('circ-1'),
              circuit: circuit,
            ),
          ),
        );

        // Act
        final result = await useCase.call(importResult: importResult).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (summary) => expect(
            summary,
            equals(
              'Committed 1 manufacturers, 1 locates, 1 device specifications, 1 devices, 1 circuits.',
            ),
          ),
        );
        verify(
          () => mockManufacturerRepository.create(item: manufacturer),
        ).called(1);
        verify(() => mockLocateRepository.create(item: locate)).called(1);
        verify(
          () => mockDeviceSpecificationRepository.create(item: deviceSpec),
        ).called(1);
        verify(() => mockDeviceRepository.create(item: device)).called(1);
        verify(() => mockCircuitRepository.create(item: circuit)).called(1);
      });
    });

    group('When import result does not pass criteria', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final importResult = ImportResult(
          issues: [
            ValidationIssue(
              severity: ValidationSeverity.error,
              message: 'Test error',
            ),
          ],
          summary: 'Test import',
          importModel: ImportModel(
            manufacturers: [],
            locates: [],
            deviceSpecifications: [],
            devices: [],
            circuits: [],
          ),
        );

        // Act
        final result = await useCase.call(importResult: importResult).run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCValidationFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When manufacturer create fails', () {
      test('Then it returns database write failure', () async {
        // Arrange
        final manufacturer = Manufacturer(name: 'Test Mfg');
        final importResult = ImportResult(
          issues: [],
          summary: 'Test import',
          importModel: ImportModel(
            manufacturers: [manufacturer],
            locates: [],
            deviceSpecifications: [],
            devices: [],
            circuits: [],
          ),
        );

        // Setup deleteAll mocks for overwrite mode
        when(
          () => mockCircuitRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockDeviceRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockDeviceSpecificationRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockLocateRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockManufacturerRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));

        when(
          () => mockManufacturerRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.left(DatastoreFailure('DB error')));

        // Act
        final result = await useCase.call(importResult: importResult).run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCDatabaseWriteFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When locate create fails', () {
      test('Then it returns database write failure', () async {
        // Arrange
        final manufacturer = Manufacturer(name: 'Test Mfg');
        final locate = Locate(name: 'Test Loc');
        final importResult = ImportResult(
          issues: [],
          summary: 'Test import',
          importModel: ImportModel(
            manufacturers: [manufacturer],
            locates: [locate],
            deviceSpecifications: [],
            devices: [],
            circuits: [],
          ),
        );
        when(
          () => mockManufacturerRepository.create(item: any(named: 'item')),
        ).thenReturn(
          TaskEither.right(
            ManufacturerWithHandle(
              handle: ManufacturerHandle('mfg-1'),
              manufacturer: manufacturer,
            ),
          ),
        );

        // Setup deleteAll mocks for overwrite mode
        when(
          () => mockCircuitRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockDeviceRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockDeviceSpecificationRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockLocateRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockManufacturerRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));

        when(
          () => mockLocateRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.left(DatastoreFailure('DB error')));

        // Act
        final result = await useCase.call(importResult: importResult).run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCDatabaseWriteFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When device specification create fails', () {
      test('Then it returns database write failure', () async {
        // Arrange
        final manufacturer = Manufacturer(name: 'Test Mfg');
        final locate = Locate(name: 'Test Loc');
        final deviceSpec = DeviceSpecification(
          typeId: 'breaker',
          modelNumber: 'QO-20',
          manufacturer: manufacturer,
        );
        final importResult = ImportResult(
          issues: [],
          summary: 'Test import',
          importModel: ImportModel(
            manufacturers: [manufacturer],
            locates: [locate],
            deviceSpecifications: [deviceSpec],
            devices: [],
            circuits: [],
          ),
        );
        when(
          () => mockManufacturerRepository.create(item: any(named: 'item')),
        ).thenReturn(
          TaskEither.right(
            ManufacturerWithHandle(
              handle: ManufacturerHandle('mfg-1'),
              manufacturer: manufacturer,
            ),
          ),
        );
        when(
          () => mockLocateRepository.create(item: any(named: 'item')),
        ).thenReturn(
          TaskEither.right(
            LocateWithHandle(handle: LocateHandle('loc-1'), locate: locate),
          ),
        );

        // Setup deleteAll mocks for overwrite mode
        when(
          () => mockCircuitRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockDeviceRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockDeviceSpecificationRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockLocateRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockManufacturerRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));

        when(
          () => mockDeviceSpecificationRepository.create(
            item: any(named: 'item'),
          ),
        ).thenReturn(TaskEither.left(DatastoreFailure('DB error')));

        // Act
        final result = await useCase.call(importResult: importResult).run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCDatabaseWriteFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When device create fails', () {
      test('Then it returns database write failure', () async {
        // Arrange
        final manufacturer = Manufacturer(name: 'Test Mfg');
        final locate = Locate(name: 'Test Loc');
        final deviceSpec = DeviceSpecification(
          typeId: 'breaker',
          modelNumber: 'QO-20',
          manufacturer: manufacturer,
        );
        final device = Device(deviceSpecification: deviceSpec);
        final importResult = ImportResult(
          issues: [],
          summary: 'Test import',
          importModel: ImportModel(
            manufacturers: [manufacturer],
            locates: [locate],
            deviceSpecifications: [deviceSpec],
            devices: [device],
            circuits: [],
          ),
        );
        when(
          () => mockManufacturerRepository.create(item: any(named: 'item')),
        ).thenReturn(
          TaskEither.right(
            ManufacturerWithHandle(
              handle: ManufacturerHandle('mfg-1'),
              manufacturer: manufacturer,
            ),
          ),
        );
        when(
          () => mockLocateRepository.create(item: any(named: 'item')),
        ).thenReturn(
          TaskEither.right(
            LocateWithHandle(handle: LocateHandle('loc-1'), locate: locate),
          ),
        );
        when(
          () => mockDeviceSpecificationRepository.create(
            item: any(named: 'item'),
          ),
        ).thenReturn(
          TaskEither.right(
            DeviceSpecificationWithHandle(
              handle: DeviceSpecificationHandle('spec-1'),
              deviceSpecification: deviceSpec,
            ),
          ),
        );

        // Setup deleteAll mocks for overwrite mode
        when(
          () => mockCircuitRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockDeviceRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockDeviceSpecificationRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockLocateRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockManufacturerRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));

        when(
          () => mockDeviceRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.left(DatastoreFailure('DB error')));

        // Act
        final result = await useCase.call(importResult: importResult).run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCDatabaseWriteFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When circuit create fails', () {
      test('Then it returns database write failure', () async {
        // Arrange
        final manufacturer = Manufacturer(name: 'Test Mfg');
        final locate = Locate(name: 'Test Loc');
        final deviceSpec = DeviceSpecification(
          typeId: 'breaker',
          modelNumber: 'QO-20',
          manufacturer: manufacturer,
        );
        final device = Device(deviceSpecification: deviceSpec);
        final circuit = Circuit(sourceDevice: device, connectedDevices: []);
        final importResult = ImportResult(
          issues: [],
          summary: 'Test import',
          importModel: ImportModel(
            manufacturers: [manufacturer],
            locates: [locate],
            deviceSpecifications: [deviceSpec],
            devices: [device],
            circuits: [circuit],
          ),
        );
        when(
          () => mockManufacturerRepository.create(item: any(named: 'item')),
        ).thenReturn(
          TaskEither.right(
            ManufacturerWithHandle(
              handle: ManufacturerHandle('mfg-1'),
              manufacturer: manufacturer,
            ),
          ),
        );
        when(
          () => mockLocateRepository.create(item: any(named: 'item')),
        ).thenReturn(
          TaskEither.right(
            LocateWithHandle(handle: LocateHandle('loc-1'), locate: locate),
          ),
        );
        when(
          () => mockDeviceSpecificationRepository.create(
            item: any(named: 'item'),
          ),
        ).thenReturn(
          TaskEither.right(
            DeviceSpecificationWithHandle(
              handle: DeviceSpecificationHandle('spec-1'),
              deviceSpecification: deviceSpec,
            ),
          ),
        );
        when(
          () => mockDeviceRepository.create(item: any(named: 'item')),
        ).thenReturn(
          TaskEither.right(
            DeviceWithHandle(handle: DeviceHandle('dev-1'), device: device),
          ),
        );

        // Setup deleteAll mocks for overwrite mode
        when(
          () => mockCircuitRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockDeviceRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockDeviceSpecificationRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockLocateRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));
        when(
          () => mockManufacturerRepository.deleteAll(),
        ).thenReturn(TaskEither.right(unit));

        when(
          () => mockCircuitRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.left(DatastoreFailure('DB error')));

        // Act
        final result = await useCase.call(importResult: importResult).run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCDatabaseWriteFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
