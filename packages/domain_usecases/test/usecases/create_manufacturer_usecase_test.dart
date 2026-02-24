import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockManufacturerRepository extends Mock
    implements ManufacturerRepository {}

class MockHandleGenerator extends Mock implements HandleGenerator {}

void main() {
  late CreateManufacturerUseCase useCase;
  late MockManufacturerRepository mockManufacturerRepository;
  late MockHandleGenerator mockHandleGenerator;

  setUpAll(() {
    registerFallbackValue(
      Manufacturer(handle: ManufacturerHandle('fallback'), name: 'fallback'),
    );
  });

  setUp(() {
    mockManufacturerRepository = MockManufacturerRepository();
    mockHandleGenerator = MockHandleGenerator();
    useCase = CreateManufacturerUseCase(
      manufacturerRepository: mockManufacturerRepository,
      handleGenerator: mockHandleGenerator,
    );
  });

  group('Given a CreateManufacturerUseCase', () {
    late MockHandleGenerator mockHandleGenerator;

    setUp(() {
      mockManufacturerRepository = MockManufacturerRepository();
      mockHandleGenerator = MockHandleGenerator();
      useCase = CreateManufacturerUseCase(
        manufacturerRepository: mockManufacturerRepository,
        handleGenerator: mockHandleGenerator,
      );
    });

    group('When executing with valid input', () {
      test('Then it returns success with expected data', () async {
        // Arrange
        final name = 'Square D';
        final handle = ManufacturerHandle('mfg-1');
        final expected = Manufacturer(handle: handle, name: name);
        final expectedWithHandle = ManufacturerWithHandle(
          handle: handle,
          manufacturer: expected,
        );
        when(
          () => mockHandleGenerator.generateManufacturerHandle(),
        ).thenReturn(handle);
        when(
          () => mockManufacturerRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.right(expectedWithHandle));

        // Act
        final result = await useCase.call(name: name).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (manufacturer) => expect(manufacturer, equals(expected)),
        );
        verify(
          () => mockHandleGenerator.generateManufacturerHandle(),
        ).called(1);
        verify(
          () => mockManufacturerRepository.create(item: any(named: 'item')),
        ).called(1);
      });
    });

    group('When repository returns failure', () {
      test('Then it propagates the failure', () async {
        // Arrange
        final handle = ManufacturerHandle('mfg-1');
        final failure = DatastoreFailure('Database error');
        when(
          () => mockHandleGenerator.generateManufacturerHandle(),
        ).thenReturn(handle);
        when(
          () => mockManufacturerRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase.call(name: 'Square D').run();

        // Should
        result.fold(
          (actualFailure) => expect(actualFailure, equals(failure)),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
