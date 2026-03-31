import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockCircuitRepository extends Mock implements CircuitRepository {}

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late CreateCircuitUseCase useCase;
  late MockCircuitRepository mockCircuitRepository;
  late MockDeviceRepository mockDeviceRepository;

  setUpAll(() {
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
    registerFallbackValue(DeviceHandle('fallback'));
  });

  group('Given a CreateCircuitUseCase', () {
    setUp(() {
      mockCircuitRepository = MockCircuitRepository();
      mockDeviceRepository = MockDeviceRepository();
      useCase = CreateCircuitUseCase(
        circuitRepository: mockCircuitRepository,
        deviceRepository: mockDeviceRepository,
      );
    });

    group('When executing with valid input', () {
      test('Then it returns success with expected data', () async {
        // Arrange
        final sourceDeviceHandle = DeviceHandle('device-1');
        final sourceDevice = Device(
          deviceSpecification: DeviceSpecification(
            typeId: 'panel',
            modelNumber: 'QO-200A',
            manufacturer: Manufacturer(name: 'Square D'),
          ),
        );
        final sourceDeviceWithHandle = DeviceWithHandle(
          handle: sourceDeviceHandle,
          device: sourceDevice,
        );
        final expected = CircuitWithHandle(
          handle: CircuitHandle('circuit-1'),
          circuit: Circuit(sourceDevice: sourceDevice, connectedDevices: []),
        );
        when(
          () => mockDeviceRepository.getByHandle(handle: sourceDeviceHandle),
        ).thenReturn(TaskEither.right(sourceDeviceWithHandle));
        when(
          () => mockCircuitRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.right(expected));

        // Act
        final result = await useCase
            .call(sourceDeviceHandle: sourceDeviceHandle)
            .run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (circuitWithHandle) => expect(circuitWithHandle, equals(expected)),
        );
        verify(
          () => mockDeviceRepository.getByHandle(handle: sourceDeviceHandle),
        ).called(1);
        verify(
          () => mockCircuitRepository.create(item: any(named: 'item')),
        ).called(1);
      });
    });

    group('When repository returns failure', () {
      test('Then it propagates the failure', () async {
        // Arrange
        final sourceDeviceHandle = DeviceHandle('device-1');
        final sourceDevice = Device(
          deviceSpecification: DeviceSpecification(
            typeId: 'panel',
            modelNumber: 'QO-200A',
            manufacturer: Manufacturer(name: 'Square D'),
          ),
        );
        final sourceDeviceWithHandle = DeviceWithHandle(
          handle: sourceDeviceHandle,
          device: sourceDevice,
        );
        final failure = DatastoreFailure('Database error');
        when(
          () => mockDeviceRepository.getByHandle(handle: sourceDeviceHandle),
        ).thenReturn(TaskEither.right(sourceDeviceWithHandle));
        when(
          () => mockCircuitRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(sourceDeviceHandle: sourceDeviceHandle)
            .run();

        // Should
        result.fold(
          (actualFailure) => expect(actualFailure, equals(failure)),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
