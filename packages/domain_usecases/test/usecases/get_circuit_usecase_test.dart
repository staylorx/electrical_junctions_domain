import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shouldly/shouldly.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockCircuitRepository extends Mock implements CircuitRepository {}

void main() {
  late GetCircuitUseCase useCase;
  late MockCircuitRepository mockCircuitRepository;

  setUpAll(() {
    registerFallbackValue(CircuitHandle('fallback'));
  });

  setUp(() {
    mockCircuitRepository = MockCircuitRepository();
    useCase = GetCircuitUseCase(circuitRepository: mockCircuitRepository);
  });

  group('Given a GetCircuitUseCase', () {
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

    group('When executing with valid handle', () {
      test('Then it returns success with circuit', () async {
        // Arrange
        when(
          () => mockCircuitRepository.getByHandle(handle: any(named: 'handle')),
        ).thenReturn(
          TaskEither.right(
            CircuitWithHandle(handle: circuitHandle, circuit: circuit),
          ),
        );

        // Act
        final result = await useCase(handle: circuitHandle).run();

        // Should
        result.fold(
          (l) => fail('Expected success, got failure: $l'),
          (r) => r.should.be(circuit),
        );

        verify(
          () => mockCircuitRepository.getByHandle(handle: circuitHandle),
        ).called(1);
      });
    });

    group('When entity not found', () {
      test('Then it returns not found failure', () async {
        // Arrange
        final failure = UCNotFoundFailure('Circuit not found');
        when(
          () => mockCircuitRepository.getByHandle(handle: any(named: 'handle')),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase(handle: circuitHandle).run();

        // Should
        result.fold((l) => l.should.be(failure), (_) => fail('Expected left'));
      });
    });

    group('When repository returns failure', () {
      test('Then it propagates the failure', () async {
        // Arrange
        final failure = UCDatabaseReadFailure('Database error');
        when(
          () => mockCircuitRepository.getByHandle(handle: any(named: 'handle')),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase(handle: circuitHandle).run();

        // Should
        result.fold((l) => l.should.be(failure), (_) => fail('Expected left'));
      });
    });
  });
}
