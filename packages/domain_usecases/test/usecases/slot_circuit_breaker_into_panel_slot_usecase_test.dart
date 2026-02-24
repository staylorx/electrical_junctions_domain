import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockDeviceRepository extends Mock implements DeviceRepository {}

class MockCircuitRepository extends Mock implements CircuitRepository {}

void main() {
  late SlotCircuitBreakerIntoPanelSlotUseCase useCase;
  late MockDeviceRepository mockDeviceRepository;
  late MockCircuitRepository mockCircuitRepository;

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
    mockDeviceRepository = MockDeviceRepository();
    mockCircuitRepository = MockCircuitRepository();
    useCase = SlotCircuitBreakerIntoPanelSlotUseCase(
      deviceRepository: mockDeviceRepository,
      circuitRepository: mockCircuitRepository,
    );
  });

  group('Given a SlotCircuitBreakerIntoPanelSlotUseCase', () {
    final manufacturer = Manufacturer(name: 'Test Mfg');
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

    group('When slotting circuit breaker successfully', () {
      test('Then it updates the panel slot', () async {
        // Arrange
        final allCircuits = [panelSlotWithHandle];
        final updatedPanelSlot = panelSlot.copyWith(
          connectedDevices: [circuitBreaker],
        );
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

        // Act
        final result = await useCase
            .call(
              circuitBreaker: circuitBreaker,
              panel: panel,
              panelSlot: panelSlotWithHandle,
            )
            .run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (circuit) =>
              expect(circuit.connectedDevices, contains(circuitBreaker)),
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
      });
    });

    group('When device is not a circuit breaker', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final nonBreaker = Device(deviceSpecification: panelSpec);

        // Act
        final result = await useCase
            .call(
              circuitBreaker: nonBreaker,
              panel: panel,
              panelSlot: panelSlotWithHandle,
            )
            .run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCValidationFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When slot is occupied', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final occupiedSlot = panelSlotWithHandle.copyWith(
          circuit: panelSlot.copyWith(
            connectedDevices: [Device(deviceSpecification: breakerSpec)],
          ),
        );
        when(
          () => mockCircuitRepository.getAll(),
        ).thenReturn(TaskEither.right([occupiedSlot]));

        // Act
        final result = await useCase
            .call(
              circuitBreaker: circuitBreaker,
              panel: panel,
              panelSlot: occupiedSlot,
            )
            .run();

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
        final result = await useCase
            .call(
              circuitBreaker: circuitBreaker,
              panel: panel,
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
