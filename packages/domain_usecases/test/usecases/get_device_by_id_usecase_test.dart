import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late GetDeviceByIdUseCase useCase;
  late MockDeviceRepository mockDeviceRepository;

  setUpAll(() {
    registerFallbackValue(DeviceHandle('fallback'));
  });

  setUp(() {
    mockDeviceRepository = MockDeviceRepository();
    useCase = GetDeviceByIdUseCase(deviceRepository: mockDeviceRepository);
  });

  group('GetDeviceByIdUseCase', () {
    final deviceHandle = DeviceHandle('device-123');
    final device = Device(
      handle: deviceHandle,
      deviceSpecification: DeviceSpecification(
        handle: DeviceSpecificationHandle('spec-1'),
        typeId: 'panel',
        modelNumber: 'QO-200A',
        manufacturer: Manufacturer(
          handle: ManufacturerHandle('mfg-1'),
          name: 'Square D',
        ),
      ),
    );

    test('should return device when found', () async {
      when(
        () => mockDeviceRepository.getByHandle(handle: any(named: 'handle')),
      ).thenReturn(TaskEither.right(device));

      final result = await useCase(handle: deviceHandle).run();

      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (resultDevice) => expect(resultDevice, equals(device)),
      );

      verify(
        () => mockDeviceRepository.getByHandle(handle: deviceHandle),
      ).called(1);
    });

    test('should return failure when device not found', () async {
      final failure = NotFoundFailure('Device not found');
      when(
        () => mockDeviceRepository.getByHandle(handle: any(named: 'handle')),
      ).thenReturn(TaskEither.left(failure));

      final result = await useCase(handle: deviceHandle).run();

      result.fold(
        (actualFailure) => expect(actualFailure, equals(failure)),
        (_) => fail('Expected failure, got success'),
      );
    });
  });
}
