import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockCircuitRepository extends Mock implements CircuitRepository {}

class MockDeviceRepository extends Mock implements DeviceRepository {}

class MockUpdateCircuitUseCase extends Mock implements UpdateCircuitUseCase {}

void main() {
  late DisconnectDeviceFromCircuitUseCase useCase;
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
    useCase = DisconnectDeviceFromCircuitUseCase(
      circuitRepository: mockCircuitRepository,
      deviceRepository: mockDeviceRepository,
      updateCircuitUseCase: mockUpdateCircuitUseCase,
    );
  });

  group('Given a DisconnectDeviceFromCircuitUseCase', () {
    final manufacturer = Manufacturer(name: 'Test Mfg');
    final deviceSpec = DeviceSpecification(
      typeId: 'breaker',
      modelNumber: 'QO-20',
      manufacturer: manufacturer,
    );
    final deviceHandle = DeviceHandle('dev-1');
    final device = Device(deviceSpecification: deviceSpec);
    final deviceWithHandle = DeviceWithHandle(
      handle: deviceHandle,
      device: device,
    );
    final sourceDevice = Device(deviceSpecification: deviceSpec);
    final circuit = Circuit(
      sourceDevice: sourceDevice,
      connectedDevices: [device],
    );
    final circuitWithHandle = CircuitWithHandle(
      handle: CircuitHandle('circ-1'),
      circuit: circuit,
    );

    group('When disconnecting device from circuit successfully', () {
      test('Then it updates the circuit and returns unit', () async {
        // Arrange
        final updatedCircuit = circuit.copyWith(connectedDevices: []);
        final updatedCircuitWithHandle = CircuitWithHandle(
          handle: circuitWithHandle.handle,
          circuit: updatedCircuit,
        );
        when(
          () => mockDeviceRepository.getByHandle(handle: deviceHandle),
        ).thenReturn(TaskEither.right(deviceWithHandle));
        when(
          () => mockUpdateCircuitUseCase.call(
            circuit: any(named: 'circuit'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(updatedCircuitWithHandle));

        // Act
        final result = await useCase
            .call(deviceHandle: deviceHandle, circuit: circuitWithHandle)
            .run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (unit) => expect(unit, equals(unit)),
        );
        verify(
          () => mockDeviceRepository.getByHandle(handle: deviceHandle),
        ).called(1);
      });
    });

    group('When device is not connected', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final circuitWithoutDevice = circuitWithHandle.copyWith(
          circuit: circuit.copyWith(connectedDevices: []),
        );
        when(
          () => mockDeviceRepository.getByHandle(handle: deviceHandle),
        ).thenReturn(TaskEither.right(deviceWithHandle));

        // Act
        final result = await useCase
            .call(deviceHandle: deviceHandle, circuit: circuitWithoutDevice)
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
          () => mockDeviceRepository.getByHandle(handle: deviceHandle),
        ).thenReturn(TaskEither.right(deviceWithHandle));
        when(
          () => mockUpdateCircuitUseCase.call(
            circuit: any(named: 'circuit'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(deviceHandle: deviceHandle, circuit: circuitWithHandle)
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
