import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockDeviceSpecificationRepository extends Mock
    implements DeviceSpecificationRepository {}

void main() {
  late CreateDeviceSpecificationUseCase useCase;
  late MockDeviceSpecificationRepository mockDeviceSpecificationRepository;

  setUpAll(() {
    registerFallbackValue(
      DeviceSpecification(
        typeId: 'fallback',
        modelNumber: 'fallback',
        manufacturer: Manufacturer(
          handle: ManufacturerHandle('fallback'),
          name: 'fallback',
        ),
        properties: {},
      ),
    );
  });

  setUp(() {
    mockDeviceSpecificationRepository = MockDeviceSpecificationRepository();
    useCase = CreateDeviceSpecificationUseCase(
      deviceSpecificationRepository: mockDeviceSpecificationRepository,
    );
  });

  group('Given a CreateDeviceSpecificationUseCase', () {
    setUp(() {
      mockDeviceSpecificationRepository = MockDeviceSpecificationRepository();
      useCase = CreateDeviceSpecificationUseCase(
        deviceSpecificationRepository: mockDeviceSpecificationRepository,
      );
    });

    group('When executing with valid input', () {
      test('Then it returns success with expected data', () async {
        // Arrange
        final manufacturer = Manufacturer(
          handle: ManufacturerHandle('mfg-1'),
          name: 'Square D',
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
          () => mockDeviceSpecificationRepository.create(
            item: any(named: 'item'),
          ),
        ).thenReturn(TaskEither.right(expectedWithHandle));

        // Act
        final result = await useCase
            .call(
              typeId: typeId,
              modelNumber: modelNumber,
              manufacturer: manufacturer,
              properties: properties,
            )
            .run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (deviceSpec) => expect(deviceSpec, equals(expected)),
        );
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
        final manufacturer = Manufacturer(
          handle: ManufacturerHandle('mfg-1'),
          name: 'Square D',
        );
        final failure = DatastoreFailure('Database error');
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
              manufacturer: manufacturer,
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
