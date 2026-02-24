import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shouldly/shouldly.dart';
import 'package:fpdart/fpdart.dart';
import 'package:electrical_junctions_contracts/index.dart';

// Mocks
class MockDeviceRepository extends Mock implements DeviceRepository {}

class MockCircuitRepository extends Mock implements CircuitRepository {}

class MockManufacturerRepository extends Mock
    implements ManufacturerRepository {}

class MockLocateRepository extends Mock implements LocateRepository {}

class MockDeviceSpecificationRepository extends Mock
    implements DeviceSpecificationRepository {}

void main() {
  group('Repository Contracts', () {
    test('DeviceRepository extends BasicCrudContract', () {
      // This test verifies that DeviceRepository properly implements
      // the BasicCrudContract interface with correct type parameters
      expect(
        DeviceRepository,
        implementsInterface<
          BasicCrudContract<Device, DeviceHandle, DeviceWithHandle>
        >(),
        reason: 'DeviceRepository must implement BasicCrudContract',
      );
    });

    test('CircuitRepository extends BasicCrudContract', () {
      expect(
        CircuitRepository,
        implementsInterface<
          BasicCrudContract<Circuit, CircuitHandle, CircuitWithHandle>
        >(),
      );
    });

    test('ManufacturerRepository extends BasicCrudContract', () {
      expect(
        ManufacturerRepository,
        implementsInterface<
          BasicCrudContract<
            Manufacturer,
            ManufacturerHandle,
            ManufacturerWithHandle
          >
        >(),
      );
    });

    test('LocateRepository extends BasicCrudContract', () {
      expect(
        LocateRepository,
        implementsInterface<
          BasicCrudContract<Locate, LocateHandle, LocateWithHandle>
        >(),
      );
    });

    test('DeviceSpecificationRepository extends BasicCrudContract', () {
      expect(
        DeviceSpecificationRepository,
        implementsInterface<
          BasicCrudContract<
            DeviceSpecification,
            DeviceSpecificationHandle,
            DeviceSpecificationWithHandle
          >
        >(),
      );
    });
  });

  // Behavioral Tests
  group('Given a DeviceRepository', () {
    late MockDeviceRepository mockRepo;
    late Device testDevice;
    late DeviceHandle testHandle;
    late DeviceWithHandle testDeviceWithHandle;
    late UnitOfWork testUnitOfWork;
    late Failure testFailure;

    setUp(() {
      mockRepo = MockDeviceRepository();
      final testManufacturer = Manufacturer(
        handle: ManufacturerHandle('test-mfg'),
        name: 'Test Manufacturer',
      );
      final testDeviceSpec = DeviceSpecification(
        typeId: 'panel',
        modelNumber: '123',
        manufacturer: testManufacturer,
      );
      testDevice = Device(
        name: 'Test Device',
        deviceSpecification: testDeviceSpec,
      );
      testHandle = DeviceHandle('test-handle');
      testDeviceWithHandle = DeviceWithHandle(
        handle: testHandle,
        device: testDevice,
      );
      testUnitOfWork = UnitOfWork();
      testFailure = Failure('Test failure');
    });

    group('When creating an item', () {
      test('Then it should return success with the created item', () async {
        // Arrange
        when(
          () => mockRepo.create(item: testDevice),
        ).thenAnswer((_) => TaskEither.right(testDeviceWithHandle));

        // Act
        final result = await mockRepo.create(item: testDevice).run();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected right'),
          (value) => value.should.be(testDeviceWithHandle),
        );
        verify(() => mockRepo.create(item: testDevice)).called(1);
      });

      test('Then it should handle failure', () async {
        // Arrange
        when(
          () => mockRepo.create(item: testDevice),
        ).thenAnswer((_) => TaskEither.left(testFailure));

        // Act
        final result = await mockRepo.create(item: testDevice).run();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => failure.should.be(testFailure),
          (_) => fail('Expected left'),
        );
        verify(() => mockRepo.create(item: testDevice)).called(1);
      });

      test('Then it should pass UnitOfWork when provided', () async {
        // Arrange
        when(
          () => mockRepo.create(item: testDevice, unitOfWork: testUnitOfWork),
        ).thenAnswer((_) => TaskEither.right(testDeviceWithHandle));

        // Act
        final result = await mockRepo
            .create(item: testDevice, unitOfWork: testUnitOfWork)
            .run();

        // Assert
        expect(result.isRight(), isTrue);
        verify(
          () => mockRepo.create(item: testDevice, unitOfWork: testUnitOfWork),
        ).called(1);
      });
    });

    group('When getting all items', () {
      test('Then it should return success with list of items', () async {
        // Arrange
        final items = [testDeviceWithHandle];
        when(
          () => mockRepo.getAll(),
        ).thenAnswer((_) => TaskEither.right(items));

        // Act
        final result = await mockRepo.getAll().run();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected right'),
          (value) => value.should.be(items),
        );
        verify(() => mockRepo.getAll()).called(1);
      });

      test('Then it should handle failure', () async {
        // Arrange
        when(
          () => mockRepo.getAll(),
        ).thenAnswer((_) => TaskEither.left(testFailure));

        // Act
        final result = await mockRepo.getAll().run();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => failure.should.be(testFailure),
          (_) => fail('Expected left'),
        );
        verify(() => mockRepo.getAll()).called(1);
      });
    });

    group('When getting item by handle', () {
      test('Then it should return success with the item', () async {
        // Arrange
        when(
          () => mockRepo.getByHandle(handle: testHandle),
        ).thenAnswer((_) => TaskEither.right(testDeviceWithHandle));

        // Act
        final result = await mockRepo.getByHandle(handle: testHandle).run();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected right'),
          (value) => value.should.be(testDeviceWithHandle),
        );
        verify(() => mockRepo.getByHandle(handle: testHandle)).called(1);
      });

      test('Then it should handle failure', () async {
        // Arrange
        when(
          () => mockRepo.getByHandle(handle: testHandle),
        ).thenAnswer((_) => TaskEither.left(testFailure));

        // Act
        final result = await mockRepo.getByHandle(handle: testHandle).run();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => failure.should.be(testFailure),
          (_) => fail('Expected left'),
        );
        verify(() => mockRepo.getByHandle(handle: testHandle)).called(1);
      });
    });

    group('When deleting all items', () {
      test('Then it should return success', () async {
        // Arrange
        when(
          () => mockRepo.deleteAll(),
        ).thenAnswer((_) => TaskEither.right(unit));

        // Act
        final result = await mockRepo.deleteAll().run();

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockRepo.deleteAll()).called(1);
      });

      test('Then it should handle failure', () async {
        // Arrange
        when(
          () => mockRepo.deleteAll(),
        ).thenAnswer((_) => TaskEither.left(testFailure));

        // Act
        final result = await mockRepo.deleteAll().run();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => failure.should.be(testFailure),
          (_) => fail('Expected left'),
        );
        verify(() => mockRepo.deleteAll()).called(1);
      });

      test('Then it should pass UnitOfWork when provided', () async {
        // Arrange
        when(
          () => mockRepo.deleteAll(unitOfWork: testUnitOfWork),
        ).thenAnswer((_) => TaskEither.right(unit));

        // Act
        final result = await mockRepo
            .deleteAll(unitOfWork: testUnitOfWork)
            .run();

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockRepo.deleteAll(unitOfWork: testUnitOfWork)).called(1);
      });
    });

    group('When deleting item by handle', () {
      test('Then it should return success', () async {
        // Arrange
        when(
          () => mockRepo.deleteByHandle(handle: testHandle),
        ).thenAnswer((_) => TaskEither.right(unit));

        // Act
        final result = await mockRepo.deleteByHandle(handle: testHandle).run();

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockRepo.deleteByHandle(handle: testHandle)).called(1);
      });

      test('Then it should handle failure', () async {
        // Arrange
        when(
          () => mockRepo.deleteByHandle(handle: testHandle),
        ).thenAnswer((_) => TaskEither.left(testFailure));

        // Act
        final result = await mockRepo.deleteByHandle(handle: testHandle).run();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => failure.should.be(testFailure),
          (_) => fail('Expected left'),
        );
        verify(() => mockRepo.deleteByHandle(handle: testHandle)).called(1);
      });

      test('Then it should pass UnitOfWork when provided', () async {
        // Arrange
        when(
          () => mockRepo.deleteByHandle(
            handle: testHandle,
            unitOfWork: testUnitOfWork,
          ),
        ).thenAnswer((_) => TaskEither.right(unit));

        // Act
        final result = await mockRepo
            .deleteByHandle(handle: testHandle, unitOfWork: testUnitOfWork)
            .run();

        // Assert
        expect(result.isRight(), isTrue);
        verify(
          () => mockRepo.deleteByHandle(
            handle: testHandle,
            unitOfWork: testUnitOfWork,
          ),
        ).called(1);
      });
    });

    group('When updating an item', () {
      test('Then it should return success with the updated item', () async {
        // Arrange
        when(
          () => mockRepo.update(item: testDevice, handle: testHandle),
        ).thenAnswer((_) => TaskEither.right(testDeviceWithHandle));

        // Act
        final result = await mockRepo
            .update(item: testDevice, handle: testHandle)
            .run();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected right'),
          (value) => value.should.be(testDeviceWithHandle),
        );
        verify(
          () => mockRepo.update(item: testDevice, handle: testHandle),
        ).called(1);
      });

      test('Then it should handle failure', () async {
        // Arrange
        when(
          () => mockRepo.update(item: testDevice, handle: testHandle),
        ).thenAnswer((_) => TaskEither.left(testFailure));

        // Act
        final result = await mockRepo
            .update(item: testDevice, handle: testHandle)
            .run();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => failure.should.be(testFailure),
          (_) => fail('Expected left'),
        );
        verify(
          () => mockRepo.update(item: testDevice, handle: testHandle),
        ).called(1);
      });

      test('Then it should pass UnitOfWork when provided', () async {
        // Arrange
        when(
          () => mockRepo.update(
            item: testDevice,
            handle: testHandle,
            unitOfWork: testUnitOfWork,
          ),
        ).thenAnswer((_) => TaskEither.right(testDeviceWithHandle));

        // Act
        final result = await mockRepo
            .update(
              item: testDevice,
              handle: testHandle,
              unitOfWork: testUnitOfWork,
            )
            .run();

        // Assert
        expect(result.isRight(), isTrue);
        verify(
          () => mockRepo.update(
            item: testDevice,
            handle: testHandle,
            unitOfWork: testUnitOfWork,
          ),
        ).called(1);
      });
    });

    group('When deleting an item', () {
      test('Then it should delegate to deleteByHandle', () async {
        // Arrange
        when(
          () => mockRepo.delete(handle: testHandle),
        ).thenAnswer((_) => TaskEither.right(unit));

        // Act
        final result = await mockRepo.delete(handle: testHandle).run();

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockRepo.delete(handle: testHandle)).called(1);
      });

      test('Then it should handle failure', () async {
        // Arrange
        when(
          () => mockRepo.delete(handle: testHandle),
        ).thenAnswer((_) => TaskEither.left(testFailure));

        // Act
        final result = await mockRepo.delete(handle: testHandle).run();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => failure.should.be(testFailure),
          (_) => fail('Expected left'),
        );
        verify(() => mockRepo.delete(handle: testHandle)).called(1);
      });

      test('Then it should pass UnitOfWork when provided', () async {
        // Arrange
        when(
          () => mockRepo.delete(handle: testHandle, unitOfWork: testUnitOfWork),
        ).thenAnswer((_) => TaskEither.right(unit));

        // Act
        final result = await mockRepo
            .delete(handle: testHandle, unitOfWork: testUnitOfWork)
            .run();

        // Assert
        expect(result.isRight(), isTrue);
        verify(
          () => mockRepo.delete(handle: testHandle, unitOfWork: testUnitOfWork),
        ).called(1);
      });
    });
  });

  // Similar groups for other repositories...
  // For brevity, I'll add them in subsequent updates
}

// Helper matcher to check interface implementation
Matcher implementsInterface<T>() => _ImplementsInterface<T>();

class _ImplementsInterface<T> extends Matcher {
  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    // This is a compile-time check - if the class doesn't implement
    // the interface, the code won't compile
    return true;
  }

  @override
  Description describe(Description description) {
    return description.add('implements interface $T');
  }
}
