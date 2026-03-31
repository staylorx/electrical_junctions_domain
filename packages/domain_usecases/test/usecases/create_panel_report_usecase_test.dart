import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockCircuitRepository extends Mock implements CircuitRepository {}

void main() {
  late CreatePanelReportUseCase useCase;
  late MockCircuitRepository mockCircuitRepository;

  setUp(() {
    mockCircuitRepository = MockCircuitRepository();
    useCase = CreatePanelReportUseCase(
      circuitRepository: mockCircuitRepository,
    );
  });

  group('Given a CreatePanelReportUseCase', () {
    setUp(() {
      mockCircuitRepository = MockCircuitRepository();
      useCase = CreatePanelReportUseCase(
        circuitRepository: mockCircuitRepository,
      );
    });

    group('When executing with valid panel', () {
      test('Then it returns success with report string', () async {
        // Arrange
        final panel = Device(
          deviceSpecification: DeviceSpecification(
            typeId: 'panel',
            modelNumber: 'QO-200A',
            manufacturer: Manufacturer(name: 'Square D'),
          ),
          locate: Locate(name: 'Main Panel'),
        );
        final circuitBreaker = Device(
          deviceSpecification: DeviceSpecification(
            typeId: 'circuit_breaker',
            modelNumber: 'QO120',
            manufacturer: Manufacturer(name: 'Square D'),
            properties: {'ampRating': 20, 'poleCount': 1},
          ),
          locate: Locate(name: 'Slot 1'),
        );
        final slotCircuit = CircuitWithHandle(
          handle: CircuitHandle('slot-1'),
          circuit: Circuit(
            stereotype: 'panel_slot',
            name: 'Slot 1',
            sourceDevice: panel,
            connectedDevices: [circuitBreaker],
          ),
        );
        final otherCircuit = CircuitWithHandle(
          handle: CircuitHandle('circuit-1'),
          circuit: Circuit(
            sourceDevice: circuitBreaker,
            connectedDevices: [
              Device(
                deviceSpecification: DeviceSpecification(
                  typeId: 'light',
                  modelNumber: 'Light1',
                  manufacturer: Manufacturer(name: 'Square D'),
                ),
                locate: Locate(name: 'Light 1'),
              ),
            ],
          ),
        );
        when(
          () => mockCircuitRepository.getAll(),
        ).thenReturn(TaskEither.right([slotCircuit, otherCircuit]));

        // Act
        final result = await useCase.call(panel: panel).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (report) => expect(report, isA<String>()),
        );
        verify(() => mockCircuitRepository.getAll()).called(1);
      });
    });

    group('When panel is not a panel', () {
      test('Then it returns validation failure', () async {
        // Arrange
        final invalidPanel = Device(
          deviceSpecification: DeviceSpecification(
            typeId: 'switch',
            modelNumber: 'Switch1',
            manufacturer: Manufacturer(name: 'Square D'),
          ),
        );

        // Act
        final result = await useCase.call(panel: invalidPanel).run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<UCValidationFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When repository returns failure', () {
      test('Then it propagates the failure', () async {
        // Arrange
        final panel = Device(
          deviceSpecification: DeviceSpecification(
            typeId: 'panel',
            modelNumber: 'QO-200A',
            manufacturer: Manufacturer(name: 'Square D'),
          ),
        );
        final failure = DatastoreFailure('Database error');
        when(
          () => mockCircuitRepository.getAll(),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase.call(panel: panel).run();

        // Should
        result.fold(
          (actualFailure) => expect(actualFailure, equals(failure)),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
