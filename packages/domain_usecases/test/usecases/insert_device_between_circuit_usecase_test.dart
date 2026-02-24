import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockCircuitRepository extends Mock implements CircuitRepository {}

void main() {
  late InsertDeviceBetweenCircuitUseCase useCase;
  late MockCircuitRepository mockCircuitRepository;

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
  });

  setUp(() {
    mockCircuitRepository = MockCircuitRepository();
    useCase = InsertDeviceBetweenCircuitUseCase(
      circuitRepository: mockCircuitRepository,
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
    final device1 = Device(deviceSpecification: deviceSpec);
    final device2 = Device(deviceSpecification: deviceSpec);
    final newDevice = Device(deviceSpecification: deviceSpec);
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
          () => mockCircuitRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(updatedCircuitWithHandle));

        // Act
        final result = await useCase
            .call(
              circuit: circuitWithHandle,
              device1: device1,
              device2: device2,
              newDevice: newDevice,
            )
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
                (c) => c.connectedDevices.contains(newDevice),
              ),
            ),
            handle: circuitWithHandle.handle,
          ),
        ).called(1);
      });
    });

    group('When devices are not found in circuit', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final otherDevice = Device(deviceSpecification: deviceSpec);
        final circuitWithoutDevices = circuitWithHandle.copyWith(
          circuit: circuit.copyWith(connectedDevices: [otherDevice]),
        );

        // Act
        final result = await useCase
            .call(
              circuit: circuitWithoutDevices,
              device1: device1,
              device2: device2,
              newDevice: newDevice,
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
        final circuitWithGap = circuitWithHandle.copyWith(
          circuit: circuit.copyWith(
            connectedDevices: [
              device1,
              Device(deviceSpecification: deviceSpec),
              device2,
            ],
          ),
        );

        // Act
        final result = await useCase
            .call(
              circuit: circuitWithGap,
              device1: device1,
              device2: device2,
              newDevice: newDevice,
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
          () => mockCircuitRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(
              circuit: circuitWithHandle,
              device1: device1,
              device2: device2,
              newDevice: newDevice,
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
