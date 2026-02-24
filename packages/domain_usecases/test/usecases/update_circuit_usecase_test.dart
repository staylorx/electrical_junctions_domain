import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shouldly/shouldly.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockCircuitRepository extends Mock implements CircuitRepository {}

void main() {
  late UpdateCircuitUseCase useCase;
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
    useCase = UpdateCircuitUseCase(circuitRepository: mockCircuitRepository);
  });

  group('Given a UpdateCircuitUseCase', () {
    final circuitHandle = CircuitHandle('circuit-123');
    final manufacturer = Manufacturer(
      handle: ManufacturerHandle('mfg-1'),
      name: 'Test Manufacturer',
    );
    final deviceSpec = DeviceSpecification(
      typeId: 'breaker',
      modelNumber: 'QO-20',
      manufacturer: manufacturer,
    );
    final sourceDevice = Device(deviceSpecification: deviceSpec);
    final circuit = Circuit(
      name: 'Test Circuit',
      sourceDevice: sourceDevice,
      connectedDevices: [],
    );

    group('When executing with valid input', () {
      test('Then it returns success with updated circuit', () async {
        // Arrange
        final updatedCircuit = Circuit(
          name: 'Updated Circuit',
          sourceDevice: sourceDevice,
          connectedDevices: [],
        );
        final circuitWithHandle = CircuitWithHandle(
          handle: circuitHandle,
          circuit: updatedCircuit,
        );
        when(
          () => mockCircuitRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(circuitWithHandle));

        // Act
        final result = await useCase
            .call(circuit: circuit, handle: circuitHandle)
            .run();

        // Should
        result.fold(
          (_) => fail('Expected right'),
          (r) => r.should.be(updatedCircuit),
        );
        verify(
          () => mockCircuitRepository.update(
            item: circuit,
            handle: circuitHandle,
          ),
        ).called(1);
      });
    });

    group('When entity not found', () {
      test('Then it returns not found failure', () async {
        // Arrange
        final failure = NotFoundFailure('Circuit not found');
        when(
          () => mockCircuitRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(circuit: circuit, handle: circuitHandle)
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
          () => mockCircuitRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(circuit: circuit, handle: circuitHandle)
            .run();

        // Should
        result.fold((l) => l.should.be(failure), (_) => fail('Expected left'));
      });
    });
  });
}
