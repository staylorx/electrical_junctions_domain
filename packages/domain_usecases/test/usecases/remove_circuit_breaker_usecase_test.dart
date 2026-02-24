import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockCircuitRepository extends Mock implements CircuitRepository {}

void main() {
  late RemoveCircuitBreakerUseCase useCase;
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
    useCase = RemoveCircuitBreakerUseCase(
      circuitRepository: mockCircuitRepository,
    );
  });

  group('Given a RemoveCircuitBreakerUseCase', () {
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
      connectedDevices: [circuitBreaker],
      stereotype: 'panel_slot',
    );
    final panelSlotWithHandle = CircuitWithHandle(
      handle: CircuitHandle('slot-1'),
      circuit: panelSlot,
    );
    final breakerCircuit = Circuit(
      sourceDevice: circuitBreaker,
      connectedDevices: [],
    );
    final breakerCircuitWithHandle = CircuitWithHandle(
      handle: CircuitHandle('circ-1'),
      circuit: breakerCircuit,
    );

    group('When removing circuit breaker successfully', () {
      test('Then it updates panel slot and deletes circuit', () async {
        // Arrange
        final allCircuits = [panelSlotWithHandle, breakerCircuitWithHandle];
        final updatedPanelSlot = panelSlot.copyWith(connectedDevices: []);
        final updatedPanelSlotWithHandle = CircuitWithHandle(
          handle: panelSlotWithHandle.handle,
          circuit: updatedPanelSlot,
        );
        when(
          () => mockCircuitRepository.getAll(),
        ).thenReturn(TaskEither.right(allCircuits));
        when(
          () => mockCircuitRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(updatedPanelSlotWithHandle));
        when(
          () => mockCircuitRepository.delete(handle: any(named: 'handle')),
        ).thenReturn(TaskEither.right(unit));

        // Act
        final result = await useCase.call(panelSlot: panelSlotWithHandle).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (unit) => expect(unit, equals(unit)),
        );
        verify(
          () => mockCircuitRepository.update(
            item: any(
              named: 'item',
              that: predicate<Circuit>((c) => c.connectedDevices.isEmpty),
            ),
            handle: panelSlotWithHandle.handle,
          ),
        ).called(1);
        verify(
          () => mockCircuitRepository.delete(
            handle: breakerCircuitWithHandle.handle,
          ),
        ).called(1);
      });
    });

    group('When circuit is not a panel slot', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final nonSlot = panelSlotWithHandle.copyWith(
          circuit: panelSlot.copyWith(stereotype: 'other'),
        );

        // Act
        final result = await useCase.call(panelSlot: nonSlot).run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCValidationFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When panel slot has no circuit breaker', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final emptySlot = panelSlotWithHandle.copyWith(
          circuit: panelSlot.copyWith(connectedDevices: []),
        );

        // Act
        final result = await useCase.call(panelSlot: emptySlot).run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCValidationFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When getAll fails', () {
      test('Then it returns failure', () async {
        // Arrange
        final failure = DatastoreFailure('DB error');
        when(
          () => mockCircuitRepository.getAll(),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase.call(panelSlot: panelSlotWithHandle).run();

        // Should
        result.fold(
          (actualFailure) => expect(actualFailure, equals(failure)),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
