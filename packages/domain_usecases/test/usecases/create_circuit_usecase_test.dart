import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockCircuitRepository extends Mock implements CircuitRepository {}

void main() {
  late CreateCircuitUseCase useCase;
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
    mockCircuitRepository = MockCircuitRepository();
    useCase = CreateCircuitUseCase(circuitRepository: mockCircuitRepository);
  });

  group('Given a CreateCircuitUseCase', () {
    setUp(() {
      mockCircuitRepository = MockCircuitRepository();
      useCase = CreateCircuitUseCase(circuitRepository: mockCircuitRepository);
    });

    group('When executing with valid input', () {
      test('Then it returns success with expected data', () async {
        // Arrange
        final sourceDevice = Device(
          deviceSpecification: DeviceSpecification(
            typeId: 'panel',
            modelNumber: 'QO-200A',
            manufacturer: Manufacturer(
              handle: ManufacturerHandle('mfg-1'),
              name: 'Square D',
            ),
          ),
        );
        final expected = CircuitWithHandle(
          handle: CircuitHandle('circuit-1'),
          circuit: Circuit(sourceDevice: sourceDevice, connectedDevices: []),
        );
        when(
          () => mockCircuitRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.right(expected));

        // Act
        final result = await useCase.call(sourceDevice: sourceDevice).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (circuitWithHandle) => expect(circuitWithHandle, equals(expected)),
        );
        verify(
          () => mockCircuitRepository.create(item: any(named: 'item')),
        ).called(1);
      });
    });

    group('When repository returns failure', () {
      test('Then it propagates the failure', () async {
        // Arrange
        final sourceDevice = Device(
          deviceSpecification: DeviceSpecification(
            typeId: 'panel',
            modelNumber: 'QO-200A',
            manufacturer: Manufacturer(
              handle: ManufacturerHandle('mfg-1'),
              name: 'Square D',
            ),
          ),
        );
        final failure = DatastoreFailure('Database error');
        when(
          () => mockCircuitRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase.call(sourceDevice: sourceDevice).run();

        // Should
        result.fold(
          (actualFailure) => expect(actualFailure, equals(failure)),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
