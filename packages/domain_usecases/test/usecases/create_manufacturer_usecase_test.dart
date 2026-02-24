import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockManufacturerRepository extends Mock
    implements ManufacturerRepository {}

void main() {
  late CreateManufacturerUseCase useCase;
  late MockManufacturerRepository mockManufacturerRepository;

  setUpAll(() {
    registerFallbackValue(Manufacturer(name: 'fallback'));
  });

  setUp(() {
    mockManufacturerRepository = MockManufacturerRepository();
    useCase = CreateManufacturerUseCase(
      manufacturerRepository: mockManufacturerRepository,
    );
  });

  group('Given a CreateManufacturerUseCase', () {
    group('When executing with valid input', () {
      test('Then it returns success with expected data', () async {
        // Arrange
        final name = 'Square D';
        final handle = ManufacturerHandle('mfg-1');
        final manufacturer = Manufacturer(name: name);
        final expectedWithHandle = ManufacturerWithHandle(
          handle: handle,
          manufacturer: manufacturer,
        );
        when(
          () => mockManufacturerRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.right(expectedWithHandle));

        // Act
        final result = await useCase.call(name: name).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (returnedManufacturer) =>
              expect(returnedManufacturer, equals(manufacturer)),
        );
        verify(
          () => mockManufacturerRepository.create(item: any(named: 'item')),
        ).called(1);
      });
    });

    group('When repository returns failure', () {
      test('Then it propagates the failure', () async {
        // Arrange
        final failure = DatastoreFailure('Database error');
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
