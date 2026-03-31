import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockDeviceRepository extends Mock implements DeviceRepository {}

class MockLocateRepository extends Mock implements LocateRepository {}

void main() {
  late CreateDeviceUseCase useCase;
  late MockDeviceRepository mockDeviceRepository;
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
    registerFallbackValue(LocateHandle('fallback'));
  });

  setUp(() {
    mockDeviceRepository = MockDeviceRepository();
    mockLocateRepository = MockLocateRepository();
    useCase = CreateDeviceUseCase(
      deviceRepository: mockDeviceRepository,
      locateRepository: mockLocateRepository,
    );
  });

  group('CreateDeviceUseCase', () {
    final deviceSpec = DeviceSpecification(
      typeId: 'panel',
      modelNumber: 'QO-200A',
      manufacturer: Manufacturer(name: 'Square D'),
    );

    final deviceHandle = DeviceHandle('device-1');
    final expectedDevice = Device(deviceSpecification: deviceSpec);
    final expectedDeviceWithHandle = DeviceWithHandle(
      handle: deviceHandle,
      device: expectedDevice,
    );

    setUp(() {
      when(
        () => mockDeviceRepository.create(item: any(named: 'item')),
      ).thenReturn(TaskEither.right(expectedDeviceWithHandle));
    });

    test('should create device with required fields', () async {
      final result = await useCase(deviceSpecification: deviceSpec).run();

      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (device) {
          expect(device.deviceSpecification, equals(deviceSpec));
          expect(device.name, isNull);
          expect(device.locate, isNull);
        },
      );

      verify(
        () => mockDeviceRepository.create(item: any(named: 'item')),
      ).called(1);
    });

    test('should create device with locate handle', () async {
      final locateHandle = LocateHandle('locate-1');
      final locate = Locate(name: 'Room 101');
      final locateWithHandle = LocateWithHandle(
        handle: locateHandle,
        locate: locate,
      );

      final deviceWithName = Device(
        name: 'Test Device',
        deviceSpecification: deviceSpec,
        locate: locate,
      );
      final deviceWithNameAndHandle = DeviceWithHandle(
        handle: deviceHandle,
        device: deviceWithName,
      );

      when(
        () => mockLocateRepository.getByHandle(handle: locateHandle),
      ).thenReturn(TaskEither.right(locateWithHandle));

      when(
        () => mockDeviceRepository.create(item: any(named: 'item')),
      ).thenReturn(TaskEither.right(deviceWithNameAndHandle));

      final result = await useCase(
        name: 'Test Device',
        deviceSpecification: deviceSpec,
        locateHandle: locateHandle,
      ).run();

      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (device) {
          expect(device.name, equals('Test Device'));
          expect(device.locate, equals(locate));
        },
      );

      verify(
        () => mockLocateRepository.getByHandle(handle: locateHandle),
      ).called(1);
    });

    test('should return failure when repository create fails', () async {
      final failure = DatastoreFailure('Database error');
      when(
        () => mockDeviceRepository.create(item: any(named: 'item')),
      ).thenReturn(TaskEither.left(failure));

      final result = await useCase(deviceSpecification: deviceSpec).run();

      result.fold(
        (actualFailure) => expect(actualFailure, equals(failure)),
        (_) => fail('Expected failure, got success'),
      );
    });
  });
}
