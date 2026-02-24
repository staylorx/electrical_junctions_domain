import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockCircuitRepository extends Mock implements CircuitRepository {}

void main() {
  late InstallCircuitBreakerUseCase useCase;
  late MockCircuitRepository mockCircuitRepository;

  setUpAll(() {
    registerFallbackValue(
      Device(
        deviceSpecification: DeviceSpecification(
          typeId: 'fallback',
          modelNumber: 'fallback',
          manufacturer: Manufacturer(
            handle: ManufacturerHandle('fallback'),
            name: 'fallback',
          ),
        ),
      ),
    );
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
    useCase = InstallCircuitBreakerUseCase(
      circuitRepository: mockCircuitRepository,
    );
  });

  group('Given a InstallCircuitBreakerUseCase', () {
    final manufacturer = Manufacturer(
      handle: ManufacturerHandle('mfg-1'),
      name: 'Test Mfg',
    );
    final panelSpec = DeviceSpecification(
      typeId: 'panel',
      modelNumber: 'QO-200A',
      manufacturer: manufacturer,
    );
    final panel = Device(deviceSpecification: panelSpec);
    final breakerSpec = DeviceSpecification(
      typeId: 'circuit_breaker',
      modelNumber: 'QO-20',
      manufacturer: manufacturer,
    );
    final circuitBreaker = Device(deviceSpecification: breakerSpec);
    final panelSlot = Circuit(
      sourceDevice: panel,
      connectedDevices: [],
      stereotype: 'panel_slot',
    );
    final panelSlotWithHandle = CircuitWithHandle(
      handle: CircuitHandle('slot-1'),
      circuit: panelSlot,
    );
    final newCircuit = Circuit(
      sourceDevice: circuitBreaker,
      connectedDevices: [],
    );
    final newCircuitWithHandle = CircuitWithHandle(
      handle: CircuitHandle('circ-1'),
      circuit: newCircuit,
    );

    group('When installing circuit breaker successfully', () {
      test('Then it updates panel slot and creates new circuit', () async {
        // Arrange
        final updatedPanelSlot = panelSlot.copyWith(
          connectedDevices: [circuitBreaker],
        );
        final updatedPanelSlotWithHandle = CircuitWithHandle(
          handle: panelSlotWithHandle.handle,
          circuit: updatedPanelSlot,
        );
        when(
          () => mockCircuitRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(updatedPanelSlotWithHandle));
        when(
          () => mockCircuitRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.right(newCircuitWithHandle));

        // Act
        final result = await useCase
            .call(
              circuitBreaker: circuitBreaker,
              panelSlot: panelSlotWithHandle,
            )
            .run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (circuit) => expect(circuit.sourceDevice, equals(circuitBreaker)),
        );
        verify(
          () => mockCircuitRepository.update(
            item: any(
              named: 'item',
              that: predicate<Circuit>(
                (c) => c.connectedDevices.contains(circuitBreaker),
              ),
            ),
            handle: panelSlotWithHandle.handle,
          ),
        ).called(1);
        verify(
          () => mockCircuitRepository.create(
            item: any(
              named: 'item',
              that: predicate<Circuit>((c) => c.sourceDevice == circuitBreaker),
            ),
          ),
        ).called(1);
      });
    });

    group('When device is not a circuit breaker', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final nonBreaker = Device(deviceSpecification: panelSpec);

        // Act
        final result = await useCase
            .call(circuitBreaker: nonBreaker, panelSlot: panelSlotWithHandle)
            .run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCValidationFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When circuit is not a panel slot', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final nonSlot = panelSlotWithHandle.copyWith(
          circuit: panelSlot.copyWith(stereotype: 'other'),
        );

        // Act
        final result = await useCase
            .call(circuitBreaker: circuitBreaker, panelSlot: nonSlot)
            .run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCValidationFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When panel slot already has devices', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final occupiedSlot = panelSlotWithHandle.copyWith(
          circuit: panelSlot.copyWith(
            connectedDevices: [Device(deviceSpecification: breakerSpec)],
          ),
        );

        // Act
        final result = await useCase
            .call(circuitBreaker: circuitBreaker, panelSlot: occupiedSlot)
            .run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCValidationFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When update fails', () {
      test('Then it returns failure', () async {
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
              circuitBreaker: circuitBreaker,
              panelSlot: panelSlotWithHandle,
            )
            .run();

        // Should
        result.fold(
          (actualFailure) => expect(actualFailure, equals(failure)),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When create fails', () {
      test('Then it returns failure', () async {
        // Arrange
        final updatedPanelSlot = panelSlot.copyWith(
          connectedDevices: [circuitBreaker],
        );
        final updatedPanelSlotWithHandle = CircuitWithHandle(
          handle: panelSlotWithHandle.handle,
          circuit: updatedPanelSlot,
        );
        final failure = DatastoreFailure('Create failed');
        when(
          () => mockCircuitRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(updatedPanelSlotWithHandle));
        when(
          () => mockCircuitRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(
              circuitBreaker: circuitBreaker,
              panelSlot: panelSlotWithHandle,
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
