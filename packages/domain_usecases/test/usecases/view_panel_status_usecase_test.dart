import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late ViewPanelStatusUseCase useCase;
  late MockDeviceRepository mockDeviceRepository;

  setUpAll(() {
    registerFallbackValue(DeviceHandle('fallback'));
  });

  setUp(() {
    mockDeviceRepository = MockDeviceRepository();
    useCase = ViewPanelStatusUseCase(deviceRepository: mockDeviceRepository);
  });

  group('Given a ViewPanelStatusUseCase', () {
    final manufacturer = Manufacturer(name: 'Test Mfg');
    final deviceSpec = DeviceSpecification(
      typeId: 'panel',
      modelNumber: 'QO-200A',
      manufacturer: manufacturer,
    );
    final device = Device(deviceSpecification: deviceSpec);
    final deviceWithHandle = DeviceWithHandle(
      handle: DeviceHandle('dev-1'),
      device: device,
    );
    final handle = DeviceHandle('dev-1');

    group('When viewing panel status successfully', () {
      test('Then it returns the device', () async {
        // Arrange
        when(
          () => mockDeviceRepository.getByHandle(handle: handle),
        ).thenReturn(TaskEither.right(deviceWithHandle));

        // Act
        final result = await useCase.call(handle: handle).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (fetchedDeviceWithHandle) =>
              expect(fetchedDeviceWithHandle, equals(deviceWithHandle)),
        );
        verify(
          () => mockDeviceRepository.getByHandle(handle: handle),
        ).called(1);
      });
    });

    group('When device not found', () {
      test('Then it returns failure', () async {
        // Arrange
        final failure = NotFoundFailure('Device not found');
        when(
          () => mockDeviceRepository.getByHandle(handle: handle),
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
