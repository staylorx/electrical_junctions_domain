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
    registerFallbackValue(DeviceHandle('fallback'));
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
    final panelHandle = DeviceHandle('panel-1');
    final panel = Device(handle: panelHandle, deviceSpecification: panelSpec);
    final panelWithHandle = DeviceWithHandle(
      handle: panelHandle,
      device: panel,
    );

    final breakerSpec = DeviceSpecification(
      typeId: 'circuit_breaker',
      modelNumber: 'QO-20',
      manufacturer: manufacturer,
    );
    final breakerHandle = DeviceHandle('breaker-1');
    final circuitBreaker = Device(
      handle: breakerHandle,
      deviceSpecification: breakerSpec,
    );
    final breakerWithHandle = DeviceWithHandle(
      handle: breakerHandle,
      device: circuitBreaker,
    );

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
          () => mockDeviceRepository.getByHandle(handle: breakerHandle),
        ).thenReturn(TaskEither.right(breakerWithHandle));
        when(
          () => mockDeviceRepository.getByHandle(handle: panelHandle),
        ).thenReturn(TaskEither.right(panelWithHandle));
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
              circuitBreakerHandle: breakerHandle,
              panelHandle: panelHandle,
              panelSlot: panelSlotWithHandle,
            )
            .run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (circuitWithHandle) => expect(
            circuitWithHandle.circuit.connectedDevices,
            contains(circuitBreaker),
          ),
        );
      });
    });

    group('When device is not a circuit breaker', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final nonBreaker = Device(
          handle: breakerHandle,
          deviceSpecification: panelSpec,
        );
        final nonBreakerWithHandle = DeviceWithHandle(
          handle: breakerHandle,
          device: nonBreaker,
        );
        when(
          () => mockDeviceRepository.getByHandle(handle: breakerHandle),
        ).thenReturn(TaskEither.right(nonBreakerWithHandle));

        // Act
        final result = await useCase
            .call(
              circuitBreakerHandle: breakerHandle,
              panelHandle: panelHandle,
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

    group('When device is not a panel', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final nonPanel = Device(
          handle: panelHandle,
          deviceSpecification: breakerSpec,
        );
        final nonPanelWithHandle = DeviceWithHandle(
          handle: panelHandle,
          device: nonPanel,
        );
        when(
          () => mockDeviceRepository.getByHandle(handle: breakerHandle),
        ).thenReturn(TaskEither.right(breakerWithHandle));
        when(
          () => mockDeviceRepository.getByHandle(handle: panelHandle),
        ).thenReturn(TaskEither.right(nonPanelWithHandle));

        // Act
        final result = await useCase
            .call(
              circuitBreakerHandle: breakerHandle,
              panelHandle: panelHandle,
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

    group('When circuit is not a panel slot', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final nonSlot = panelSlotWithHandle.copyWith(
          circuit: panelSlot.copyWith(stereotype: 'other'),
        );

        // Act
        final result = await useCase
            .call(
              circuitBreakerHandle: breakerHandle,
              panelHandle: panelHandle,
              panelSlot: nonSlot,
            )
            .run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCValidationFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
