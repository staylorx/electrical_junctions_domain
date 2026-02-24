import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockDeviceRepository extends Mock implements DeviceRepository {}

class MockCircuitRepository extends Mock implements CircuitRepository {}

class MockLocateRepository extends Mock implements LocateRepository {}

void main() {
  late GenerateDeviceReportsUseCase useCase;
  late MockDeviceRepository mockDeviceRepository;
  late MockCircuitRepository mockCircuitRepository;
  late MockLocateRepository mockLocateRepository;

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
    registerFallbackValue(Locate(name: 'fallback'));
  });

  setUp(() {
    mockDeviceRepository = MockDeviceRepository();
    mockCircuitRepository = MockCircuitRepository();
    mockLocateRepository = MockLocateRepository();
    useCase = GenerateDeviceReportsUseCase(
      deviceRepository: mockDeviceRepository,
      circuitRepository: mockCircuitRepository,
      locateRepository: mockLocateRepository,
    );
  });

  group('Given a GenerateDeviceReportsUseCase', () {
    final manufacturer = Manufacturer(
      handle: ManufacturerHandle('mfg-1'),
      name: 'Test Mfg',
    );
    final deviceSpec = DeviceSpecification(
      typeId: 'breaker',
      modelNumber: 'QO-20',
      manufacturer: manufacturer,
    );
    final device = Device(deviceSpecification: deviceSpec);
    final deviceWithHandle = DeviceWithHandle(
      handle: DeviceHandle('dev-1'),
      device: device,
    );
    final circuit = Circuit(sourceDevice: device, connectedDevices: []);
    final circuitWithHandle = CircuitWithHandle(
      handle: CircuitHandle('circ-1'),
      circuit: circuit,
    );

    group('When generating reports successfully', () {
      test('Then it returns list of device reports', () async {
        // Arrange
        when(
          () => mockDeviceRepository.getAll(),
        ).thenReturn(TaskEither.right([deviceWithHandle]));
        when(
          () => mockCircuitRepository.getAll(),
        ).thenReturn(TaskEither.right([circuitWithHandle]));

        // Act
        final result = await useCase.call().run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (reports) => expect(reports, isA<List<DeviceReportData>>()),
        );
        verify(() => mockDeviceRepository.getAll()).called(1);
        verify(() => mockCircuitRepository.getAll()).called(1);
      });
    });

    group('When device repository fails', () {
      test('Then it returns failure', () async {
        // Arrange
        final failure = DatastoreFailure('DB error');
        when(
          () => mockDeviceRepository.getAll(),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase.call().run();

        // Should
        result.fold(
          (actualFailure) => expect(actualFailure, equals(failure)),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When circuit repository fails', () {
      test('Then it returns failure', () async {
        // Arrange
        final failure = DatastoreFailure('DB error');
        when(
          () => mockDeviceRepository.getAll(),
        ).thenReturn(TaskEither.right([deviceWithHandle]));
        when(
          () => mockCircuitRepository.getAll(),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase.call().run();

        // Should
        result.fold(
          (actualFailure) => expect(actualFailure, equals(failure)),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
