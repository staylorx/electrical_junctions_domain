import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockDeviceSpecificationRepository extends Mock
    implements DeviceSpecificationRepository {}

class MockDeviceSpecificationSchemaService extends Mock
    implements IDeviceSpecificationSchemaService {}

class MockPropertyAccessor extends Mock implements PropertyAccessor<dynamic> {}

void main() {
  late SetDeviceSpecificationPropertyUseCase useCase;
  late MockDeviceSpecificationRepository mockDeviceSpecificationRepository;
  late MockDeviceSpecificationSchemaService mockSchemaService;

  setUpAll(() {
    registerFallbackValue(
      DeviceSpecification(
        typeId: 'fallback',
        modelNumber: 'fallback',
        manufacturer: Manufacturer(name: 'fallback'),
      ),
    );
    registerFallbackValue(DeviceSpecificationHandle('fallback'));
  });

  setUp(() {
    mockDeviceSpecificationRepository = MockDeviceSpecificationRepository();
    mockSchemaService = MockDeviceSpecificationSchemaService();
    useCase = SetDeviceSpecificationPropertyUseCase(
      deviceSpecificationRepository: mockDeviceSpecificationRepository,
      schemaService: mockSchemaService,
    );
  });

  group('Given a SetDeviceSpecificationPropertyUseCase', () {
    final manufacturer = Manufacturer(name: 'Test Mfg');
    final deviceSpec = DeviceSpecification(
      typeId: 'breaker',
      modelNumber: 'QO-20',
      manufacturer: manufacturer,
    );
    final deviceSpecWithHandle = DeviceSpecificationWithHandle(
      handle: DeviceSpecificationHandle('spec-1'),
      deviceSpecification: deviceSpec,
    );
    final handle = DeviceSpecificationHandle('spec-1');

    group('When setting property successfully', () {
      test('Then it updates the device specification', () async {
        // Arrange
        final accessor = MockPropertyAccessor();
        when(
          () => mockDeviceSpecificationRepository.getByHandle(handle: handle),
        ).thenReturn(TaskEither.right(deviceSpecWithHandle));
        when(
          () => mockSchemaService.getPropertyAccessorFP('breaker', 'ampRating'),
        ).thenReturn(Right(accessor));
        when(
          () => mockSchemaService.validatePropertiesFP('breaker', any()),
        ).thenReturn(Right(unit));
        when(
          () => mockDeviceSpecificationRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(deviceSpecWithHandle));

        // Act
        final result = await useCase
            .call(handle: handle, propertyKey: 'ampRating', value: 20)
            .run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (unit) => expect(unit, equals(unit)),
        );
        verify(
          () => mockDeviceSpecificationRepository.update(
            item: any(named: 'item'),
            handle: handle,
          ),
        ).called(1);
      });
    });

    group('When device specification not found', () {
      test('Then it returns failure', () async {
        // Arrange
        final failure = NotFoundFailure('Not found');
        when(
          () => mockDeviceSpecificationRepository.getByHandle(handle: handle),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(handle: handle, propertyKey: 'ampRating', value: 20)
            .run();

        // Should
        result.fold(
          (actualFailure) => expect(actualFailure, equals(failure)),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When property accessor fails', () {
      test('Then it returns failure', () async {
        // Arrange
        when(
          () => mockDeviceSpecificationRepository.getByHandle(handle: handle),
        ).thenReturn(TaskEither.right(deviceSpecWithHandle));
        when(
          () => mockSchemaService.getPropertyAccessorFP('breaker', 'ampRating'),
        ).thenReturn(
          Left(InvalidPropertyDefinitionFailure('ampRating', 'Invalid')),
        );

        // Act
        final result = await useCase
            .call(handle: handle, propertyKey: 'ampRating', value: 20)
            .run();

        // Should
        result.fold(
          (failure) => expect(failure, isA<InvalidPropertyDefinitionFailure>()),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
