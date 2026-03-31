import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockDeviceRepository extends Mock implements DeviceRepository {}

class MockManufacturerRepository extends Mock
    implements ManufacturerRepository {}

class MockLocateRepository extends Mock implements LocateRepository {}

void main() {
  late SearchDevicesUseCase useCase;
  late MockDeviceRepository mockDeviceRepository;
  late MockManufacturerRepository mockManufacturerRepository;
  late MockLocateRepository mockLocateRepository;

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
    registerFallbackValue(ManufacturerHandle('fallback'));
    registerFallbackValue(LocateHandle('fallback'));
  });

  setUp(() {
    mockDeviceRepository = MockDeviceRepository();
    mockManufacturerRepository = MockManufacturerRepository();
    mockLocateRepository = MockLocateRepository();
    useCase = SearchDevicesUseCase(
      deviceRepository: mockDeviceRepository,
      manufacturerRepository: mockManufacturerRepository,
      locateRepository: mockLocateRepository,
    );
  });

  group('Given a SearchDevicesUseCase', () {
    final manufacturer = Manufacturer(name: 'Test Mfg');
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

    group('When searching devices successfully', () {
      test('Then it returns filtered devices', () async {
        // Arrange
        when(
          () => mockDeviceRepository.getDevicesByType('breaker'),
        ).thenReturn(TaskEither.right([deviceWithHandle]));

        // Act
        final result = await useCase.call(typeId: 'breaker').run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (devices) => expect(devices, contains(device)),
        );
        verify(
          () => mockDeviceRepository.getDevicesByType('breaker'),
        ).called(1);
      });
    });

    group('When repository fails', () {
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
  });
}
