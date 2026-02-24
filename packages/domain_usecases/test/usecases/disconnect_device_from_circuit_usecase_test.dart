import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockCircuitRepository extends Mock implements CircuitRepository {}

void main() {
  late DisconnectDeviceFromCircuitUseCase useCase;
  late MockCircuitRepository mockCircuitRepository;

  setUpAll(() {
    registerFallbackValue(
      Circuit(
        sourceDevice: Device(
          deviceSpecification: DeviceSpecification(
            typeId: 'fallback',
            modelNumber: 'fallback',
            manufacturer: Manufacturer(
              handle: ManufacturerHandle('fallback'),
              name: 'fallback',
            ),
          ),
        ),
        connectedDevices: [],
      ),
    );
    registerFallbackValue(CircuitHandle('fallback'));
  });

  setUp(() {
    mockCircuitRepository = MockCircuitRepository();
    useCase = DisconnectDeviceFromCircuitUseCase(
      circuitRepository: mockCircuitRepository,
    );
  });

  group('Given a DisconnectDeviceFromCircuitUseCase', () {
    final manufacturer = Manufacturer(
      handle: ManufacturerHandle('mfg-1'),
      name: 'Test Mfg',
    );
    final deviceSpec = DeviceSpecification(
      typeId: 'breaker',
      modelNumber: 'QO-20',
      manufacturer: manufacturer,
    );
    final device = Device(deviceSpecification: deviceSpec);
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
          () => mockCircuitRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(updatedCircuitWithHandle));

        // Act
        final result = await useCase
            .call(device: device, circuit: circuitWithHandle)
            .run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (unit) => expect(unit, equals(unit)),
        );
        verify(
          () => mockCircuitRepository.update(
            item: any(
              named: 'item',
              that: predicate<Circuit>(
                (c) => !c.connectedDevices.contains(device),
              ),
            ),
            handle: circuitWithHandle.handle,
          ),
        ).called(1);
      });
    });

    group('When device is not connected', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final circuitWithoutDevice = circuitWithHandle.copyWith(
          circuit: circuit.copyWith(connectedDevices: []),
        );

        // Act
        final result = await useCase
            .call(device: device, circuit: circuitWithoutDevice)
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
          () => mockCircuitRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(device: device, circuit: circuitWithHandle)
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
