import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shouldly/shouldly.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late UpdateDeviceUseCase useCase;
  late MockDeviceRepository mockDeviceRepository;

  setUpAll(() {
    registerFallbackValue(
      Device(
        deviceSpecification: DeviceSpecification(
          typeId: 'fallback',
          modelNumber: 'fallback',
          manufacturer: Manufacturer(name: 'fallback'),
        ),
      ),
    );
    registerFallbackValue(DeviceHandle('fallback'));
  });

  setUp(() {
    mockDeviceRepository = MockDeviceRepository();
    useCase = UpdateDeviceUseCase(deviceRepository: mockDeviceRepository);
  });

  group('Given a UpdateDeviceUseCase', () {
    final handle = DeviceHandle('device-123');
    final manufacturer = Manufacturer(name: 'Test Manufacturer');
    final deviceSpec = DeviceSpecification(
      typeId: 'breaker',
      modelNumber: 'QO-20',
      manufacturer: manufacturer,
    );
    final existingDevice = Device(
      name: 'Old Name',
      deviceSpecification: deviceSpec,
    );
    final existingDeviceWithHandle = DeviceWithHandle(
      handle: handle,
      device: existingDevice,
    );

    group('When executing with valid input', () {
      test('Then it returns success with updated device', () async {
        // Arrange
        final newDeviceSpec = DeviceSpecification(
          typeId: 'breaker',
          modelNumber: 'QO-30',
          manufacturer: manufacturer,
        );
        final updatedDevice = Device(
          name: 'New Name',
          deviceSpecification: newDeviceSpec,
        );
        final updatedDeviceWithHandle = DeviceWithHandle(
          handle: handle,
          device: updatedDevice,
        );
        when(
          () => mockDeviceRepository.getByHandle(handle: any(named: 'handle')),
        ).thenReturn(TaskEither.right(existingDeviceWithHandle));
        when(
          () => mockDeviceRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(updatedDeviceWithHandle));

        // Act
        final result = await useCase
            .call(
              name: 'New Name',
              deviceSpecification: newDeviceSpec,
              handle: handle,
            )
            .run();

        // Should
        result.fold(
          (_) => fail('Expected right'),
          (r) => r.should.be(updatedDevice),
        );
        verify(
          () => mockDeviceRepository.getByHandle(handle: handle),
        ).called(1);
        verify(
          () =>
              mockDeviceRepository.update(item: updatedDevice, handle: handle),
        ).called(1);
      });
    });

    group('When entity not found', () {
      test('Then it returns not found failure', () async {
        // Arrange
        final failure = NotFoundFailure('Device not found');
        when(
          () => mockDeviceRepository.getByHandle(handle: any(named: 'handle')),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(
              name: 'New Name',
              deviceSpecification: deviceSpec,
              handle: handle,
            )
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
          () => mockDeviceRepository.getByHandle(handle: any(named: 'handle')),
        ).thenReturn(TaskEither.right(existingDeviceWithHandle));
        when(
          () => mockDeviceRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(
              name: 'New Name',
              deviceSpecification: deviceSpec,
              handle: handle,
            )
            .run();

        // Should
        result.fold((l) => l.should.be(failure), (_) => fail('Expected left'));
      });
    });
  });
}
