import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockDeviceSpecificationRepository extends Mock
    implements DeviceSpecificationRepository {}

class MockManufacturerRepository extends Mock
    implements ManufacturerRepository {}

void main() {
  late CreateDeviceSpecificationUseCase useCase;
  late MockDeviceSpecificationRepository mockDeviceSpecificationRepository;
  late MockManufacturerRepository mockManufacturerRepository;

  setUpAll(() {
    registerFallbackValue(
      DeviceSpecification(
        typeId: 'fallback',
        modelNumber: 'fallback',
        manufacturer: Manufacturer(name: 'fallback'),
        properties: {},
      ),
    );
    registerFallbackValue(ManufacturerHandle('fallback'));
  });

  group('Given a CreateDeviceSpecificationUseCase', () {
    setUp(() {
      mockDeviceSpecificationRepository = MockDeviceSpecificationRepository();
      mockManufacturerRepository = MockManufacturerRepository();
      useCase = CreateDeviceSpecificationUseCase(
        deviceSpecificationRepository: mockDeviceSpecificationRepository,
        manufacturerRepository: mockManufacturerRepository,
      );
    });

    group('When executing with valid input', () {
      test('Then it returns success with expected data', () async {
        // Arrange
        final manufacturerHandle = ManufacturerHandle('mfg-1');
        final manufacturer = Manufacturer(name: 'Square D');
        final manufacturerWithHandle = ManufacturerWithHandle(
          handle: manufacturerHandle,
          manufacturer: manufacturer,
        );
        final typeId = 'panel';
        final modelNumber = 'QO-200A';
        final properties = <String, dynamic>{'ampRating': 200};
        final expected = DeviceSpecification(
          typeId: typeId,
          modelNumber: modelNumber,
          manufacturer: manufacturer,
          properties: properties,
        );
        final expectedWithHandle = DeviceSpecificationWithHandle(
          handle: DeviceSpecificationHandle('spec-1'),
          deviceSpecification: expected,
        );
        when(
          () => mockManufacturerRepository.getByHandle(
            handle: manufacturerHandle,
          ),
        ).thenReturn(TaskEither.right(manufacturerWithHandle));
        when(
          () => mockDeviceSpecificationRepository.create(
            item: any(named: 'item'),
          ),
        ).thenReturn(TaskEither.right(expectedWithHandle));

        // Act
        final result = await useCase
            .call(
              typeId: typeId,
              modelNumber: modelNumber,
              manufacturerHandle: manufacturerHandle,
              properties: properties,
            )
            .run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (deviceSpec) => expect(deviceSpec, equals(expectedWithHandle)),
        );
        verify(
          () => mockManufacturerRepository.getByHandle(
            handle: manufacturerHandle,
          ),
        ).called(1);
        verify(
          () => mockDeviceSpecificationRepository.create(
            item: any(named: 'item'),
          ),
        ).called(1);
      });
    });

    group('When repository returns failure', () {
      test('Then it propagates the failure', () async {
        // Arrange
        final manufacturerHandle = ManufacturerHandle('mfg-1');
        final manufacturer = Manufacturer(name: 'Square D');
        final manufacturerWithHandle = ManufacturerWithHandle(
          handle: manufacturerHandle,
          manufacturer: manufacturer,
        );
        final failure = DatastoreFailure('Database error');
        when(
          () => mockManufacturerRepository.getByHandle(
            handle: manufacturerHandle,
          ),
        ).thenReturn(TaskEither.right(manufacturerWithHandle));
        when(
          () => mockDeviceSpecificationRepository.create(
            item: any(named: 'item'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(
              typeId: 'panel',
              modelNumber: 'QO-200A',
              manufacturerHandle: manufacturerHandle,
            )
            .run();

        // Should
        result.fold(
          (actualFailure) => expect(actualFailure, equals(failure)),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
