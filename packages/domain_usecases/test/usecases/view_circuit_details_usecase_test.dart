import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockCircuitRepository extends Mock implements CircuitRepository {}

void main() {
  late ViewCircuitDetailsUseCase useCase;
  late MockCircuitRepository mockCircuitRepository;

  setUpAll(() {
    registerFallbackValue(CircuitHandle('fallback'));
  });

  setUp(() {
    mockCircuitRepository = MockCircuitRepository();
    useCase = ViewCircuitDetailsUseCase(
      circuitRepository: mockCircuitRepository,
    );
  });

  group('Given a ViewCircuitDetailsUseCase', () {
    final manufacturer = Manufacturer(name: 'Test Mfg');
    final deviceSpec = DeviceSpecification(
      typeId: 'breaker',
      modelNumber: 'QO-20',
      manufacturer: manufacturer,
    );
    final device = Device(deviceSpecification: deviceSpec);
    final circuit = Circuit(sourceDevice: device, connectedDevices: []);
    final circuitWithHandle = CircuitWithHandle(
      handle: CircuitHandle('circ-1'),
      circuit: circuit,
    );
    final handle = CircuitHandle('circ-1');

    group('When viewing circuit details successfully', () {
      test('Then it returns the circuit', () async {
        // Arrange
        when(
          () => mockCircuitRepository.getByHandle(handle: handle),
        ).thenReturn(TaskEither.right(circuitWithHandle));

        // Act
        final result = await useCase.call(handle: handle).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (fetchedCircuitWithHandle) =>
              expect(fetchedCircuitWithHandle, equals(circuitWithHandle)),
        );
        verify(
          () => mockCircuitRepository.getByHandle(handle: handle),
        ).called(1);
      });
    });

    group('When circuit not found', () {
      test('Then it returns failure', () async {
        // Arrange
        final failure = NotFoundFailure('Circuit not found');
        when(
          () => mockCircuitRepository.getByHandle(handle: handle),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase.call(handle: handle).run();

        // Should
        result.fold(
          (actualFailure) => expect(actualFailure, equals(failure)),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
