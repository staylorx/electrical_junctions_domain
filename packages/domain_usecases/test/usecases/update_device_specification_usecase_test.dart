import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shouldly/shouldly.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockDeviceSpecificationRepository extends Mock
    implements DeviceSpecificationRepository {}

void main() {
  late UpdateDeviceSpecificationUseCase useCase;
  late MockDeviceSpecificationRepository mockDeviceSpecificationRepository;

  setUpAll(() {
    registerFallbackValue(
      DeviceSpecification(
        typeId: 'fallback',
        modelNumber: 'fallback',
        manufacturer: Manufacturer(name: 'fallback'),
      ),
    );
    registerFallbackValue(DeviceSpecificationHandle('fallback'));
  });

  setUp(() {
    mockDeviceSpecificationRepository = MockDeviceSpecificationRepository();
    useCase = UpdateDeviceSpecificationUseCase(
      deviceSpecificationRepository: mockDeviceSpecificationRepository,
    );
  });

  group('Given a UpdateDeviceSpecificationUseCase', () {
    final handle = DeviceSpecificationHandle('spec-123');
    final manufacturer = Manufacturer(name: 'Test Manufacturer');
    final deviceSpec = DeviceSpecification(
      typeId: 'breaker',
      modelNumber: 'QO-20',
      manufacturer: manufacturer,
    );

    group('When executing with valid input', () {
      test(
        'Then it returns success with updated device specification',
        () async {
          // Arrange
          final updatedDeviceSpec = DeviceSpecification(
            typeId: 'breaker',
            modelNumber: 'QO-30',
            manufacturer: manufacturer,
          );
          final deviceSpecWithHandle = DeviceSpecificationWithHandle(
            handle: handle,
            deviceSpecification: updatedDeviceSpec,
          );
          when(
            () => mockDeviceSpecificationRepository.update(
              item: any(named: 'item'),
              handle: any(named: 'handle'),
            ),
          ).thenReturn(TaskEither.right(deviceSpecWithHandle));

          // Act
          final result = await useCase
              .call(deviceSpecification: deviceSpec, handle: handle)
              .run();

          // Should
          result.fold(
            (_) => fail('Expected right'),
            (r) => r.should.be(updatedDeviceSpec),
          );
          verify(
            () => mockDeviceSpecificationRepository.update(
              item: deviceSpec,
              handle: handle,
            ),
          ).called(1);
        },
      );
    });

    group('When entity not found', () {
      test('Then it returns not found failure', () async {
        // Arrange
        final failure = NotFoundFailure('Device specification not found');
        when(
          () => mockDeviceSpecificationRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(deviceSpecification: deviceSpec, handle: handle)
            .run();

        // Should
        result.fold((l) => l.should.be(failure), (_) => fail('Expected left'));
      });
    });

    group('When repository returns failure', () {
      test('Then it propagates the failure', () async {
        // Arrange
        final failure = DatastoreFailure('Database error');
        when(
          () => mockDeviceSpecificationRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(deviceSpecification: deviceSpec, handle: handle)
            .run();

        // Should
        result.fold((l) => l.should.be(failure), (_) => fail('Expected left'));
      });
    });
  });
}
