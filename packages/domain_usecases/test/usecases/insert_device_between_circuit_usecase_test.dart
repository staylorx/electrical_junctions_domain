import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockCircuitRepository extends Mock implements CircuitRepository {}

class MockDeviceRepository extends Mock implements DeviceRepository {}

class MockUpdateCircuitUseCase extends Mock implements UpdateCircuitUseCase {}

void main() {
  late InsertDeviceBetweenCircuitUseCase useCase;
  late MockCircuitRepository mockCircuitRepository;
  late MockDeviceRepository mockDeviceRepository;
  late MockUpdateCircuitUseCase mockUpdateCircuitUseCase;

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
    registerFallbackValue(CircuitHandle('fallback'));
    registerFallbackValue(DeviceHandle('fallback'));
  });

  setUp(() {
    mockCircuitRepository = MockCircuitRepository();
    mockDeviceRepository = MockDeviceRepository();
    mockUpdateCircuitUseCase = MockUpdateCircuitUseCase();
    useCase = InsertDeviceBetweenCircuitUseCase(
      circuitRepository: mockCircuitRepository,
      deviceRepository: mockDeviceRepository,
      updateCircuitUseCase: mockUpdateCircuitUseCase,
    );
  });

  group('Given a InsertDeviceBetweenCircuitUseCase', () {
    final manufacturer = Manufacturer(name: 'Test Mfg');
    final deviceSpec = DeviceSpecification(
      typeId: 'breaker',
      modelNumber: 'QO-20',
      manufacturer: manufacturer,
    );
    final sourceDevice = Device(deviceSpecification: deviceSpec);
    final device1Handle = DeviceHandle('dev-1');
    final device2Handle = DeviceHandle('dev-2');
    final newDeviceHandle = DeviceHandle('dev-3');

    final device1 = Device(deviceSpecification: deviceSpec);
    final device2 = Device(deviceSpecification: deviceSpec);
    final newDevice = Device(deviceSpecification: deviceSpec);

    final device1WithHandle = DeviceWithHandle(
      handle: device1Handle,
      device: device1,
    );
    final device2WithHandle = DeviceWithHandle(
      handle: device2Handle,
      device: device2,
    );
    final newDeviceWithHandle = DeviceWithHandle(
      handle: newDeviceHandle,
      device: newDevice,
    );

    final circuit = Circuit(
      sourceDevice: sourceDevice,
      connectedDevices: [device1, device2],
    );
    final circuitWithHandle = CircuitWithHandle(
      handle: CircuitHandle('circ-1'),
      circuit: circuit,
    );

    group('When inserting device between consecutive devices successfully', () {
      test('Then it updates the circuit and returns unit', () async {
        // Arrange
        final updatedCircuit = circuit.copyWith(
          connectedDevices: [device1, newDevice, device2],
        );
        final updatedCircuitWithHandle = CircuitWithHandle(
          handle: circuitWithHandle.handle,
          circuit: updatedCircuit,
        );
        when(
          () => mockDeviceRepository.getByHandle(handle: device1Handle),
        ).thenReturn(TaskEither.right(device1WithHandle));
        when(
          () => mockDeviceRepository.getByHandle(handle: device2Handle),
        ).thenReturn(TaskEither.right(device2WithHandle));
        when(
          () => mockDeviceRepository.getByHandle(handle: newDeviceHandle),
        ).thenReturn(TaskEither.right(newDeviceWithHandle));
        when(
          () => mockUpdateCircuitUseCase.call(
            circuit: any(named: 'circuit'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(updatedCircuitWithHandle));

        // Act
        final result = await useCase
            .call(
              circuit: circuitWithHandle,
              device1Handle: device1Handle,
              device2Handle: device2Handle,
              newDeviceHandle: newDeviceHandle,
            )
            .run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (unit) => expect(unit, equals(unit)),
        );
        verify(
          () => mockDeviceRepository.getByHandle(handle: device1Handle),
        ).called(1);
        verify(
          () => mockDeviceRepository.getByHandle(handle: device2Handle),
        ).called(1);
        verify(
          () => mockDeviceRepository.getByHandle(handle: newDeviceHandle),
        ).called(1);
      });
    });

    group('When devices are not found in circuit', () {
      test('Then it returns validation failure', () async {
        // Arrange
        when(
          () => mockDeviceRepository.getByHandle(handle: device1Handle),
        ).thenReturn(TaskEither.right(device1WithHandle));
        when(
          () => mockDeviceRepository.getByHandle(handle: device2Handle),
        ).thenReturn(TaskEither.right(device2WithHandle));
        when(
          () => mockDeviceRepository.getByHandle(handle: newDeviceHandle),
        ).thenReturn(TaskEither.right(newDeviceWithHandle));

        final otherDevice = Device(deviceSpecification: deviceSpec);
        final circuitWithOther = circuitWithHandle.copyWith(
          circuit: circuit.copyWith(connectedDevices: [otherDevice]),
        );

        // Act
        final result = await useCase
            .call(
              circuit: circuitWithOther,
              device1Handle: device1Handle,
              device2Handle: device2Handle,
              newDeviceHandle: newDeviceHandle,
            )
            .run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCValidationFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When devices are not consecutive', () {
      test('Then it returns validation failure', () async {
        // Arrange
        when(
          () => mockDeviceRepository.getByHandle(handle: device1Handle),
        ).thenReturn(TaskEither.right(device1WithHandle));
        when(
          () => mockDeviceRepository.getByHandle(handle: device2Handle),
        ).thenReturn(TaskEither.right(device2WithHandle));
        when(
          () => mockDeviceRepository.getByHandle(handle: newDeviceHandle),
        ).thenReturn(TaskEither.right(newDeviceWithHandle));

        final otherDevice = Device(deviceSpecification: deviceSpec);
        final circuitWithOther = circuitWithHandle.copyWith(
          circuit: circuit.copyWith(
            connectedDevices: [device1, otherDevice, device2],
          ),
        );

        // Act
        final result = await useCase
            .call(
              circuit: circuitWithOther,
              device1Handle: device1Handle,
              device2Handle: device2Handle,
              newDeviceHandle: newDeviceHandle,
            )
            .run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCValidationFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When update circuit fails', () {
      test('Then it propagates the failure', () async {
        // Arrange
        final failure = DatastoreFailure('Update failed');
        when(
          () => mockDeviceRepository.getByHandle(handle: device1Handle),
        ).thenReturn(TaskEither.right(device1WithHandle));
        when(
          () => mockDeviceRepository.getByHandle(handle: device2Handle),
        ).thenReturn(TaskEither.right(device2WithHandle));
        when(
          () => mockDeviceRepository.getByHandle(handle: newDeviceHandle),
        ).thenReturn(TaskEither.right(newDeviceWithHandle));
        when(
          () => mockUpdateCircuitUseCase.call(
            circuit: any(named: 'circuit'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(
              circuit: circuitWithHandle,
              device1Handle: device1Handle,
              device2Handle: device2Handle,
              newDeviceHandle: newDeviceHandle,
            )
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
