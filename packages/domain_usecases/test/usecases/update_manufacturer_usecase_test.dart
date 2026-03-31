import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shouldly/shouldly.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockManufacturerRepository extends Mock
    implements ManufacturerRepository {}

void main() {
  late UpdateManufacturerUseCase useCase;
  late MockManufacturerRepository mockManufacturerRepository;

  setUpAll(() {
    registerFallbackValue(Manufacturer(name: 'fallback'));
    registerFallbackValue(ManufacturerHandle('fallback'));
  });

  setUp(() {
    mockManufacturerRepository = MockManufacturerRepository();
    useCase = UpdateManufacturerUseCase(
      manufacturerRepository: mockManufacturerRepository,
    );
  });

  group('Given a UpdateManufacturerUseCase', () {
    final handle = ManufacturerHandle('mfg-123');
    final manufacturer = Manufacturer(name: 'Test Manufacturer');

    group('When executing with valid input', () {
      test('Then it returns success with updated manufacturer', () async {
        // Arrange
        final updatedManufacturer = Manufacturer(name: 'Updated Manufacturer');
        final manufacturerWithHandle = ManufacturerWithHandle(
          handle: handle,
          manufacturer: updatedManufacturer,
        );
        when(
          () => mockManufacturerRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(manufacturerWithHandle));

        // Act
        final result = await useCase
            .call(manufacturer: manufacturer, handle: handle)
            .run();

        // Should
        result.fold(
          (l) => throw 'Expected right, but got left: $l',
          (r) => r.should.be(manufacturerWithHandle),
        );
        verify(
          () => mockManufacturerRepository.update(
            item: manufacturer,
            handle: handle,
          ),
        ).called(1);
      });
    });

    group('When entity not found', () {
      test('Then it returns not found failure', () async {
        // Arrange
        final failure = NotFoundFailure('Manufacturer not found');
        when(
          () => mockManufacturerRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(manufacturer: manufacturer, handle: handle)
            .run();

        // Should
        result.fold(
          (l) => l.should.be(failure),
          (r) => throw 'Expected left, but got right: $r',
        );
      });
    });

    group('When repository returns failure', () {
      test('Then it propagates the failure', () async {
        // Arrange
        final failure = DatastoreFailure('Database error');
        when(
          () => mockManufacturerRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase
            .call(manufacturer: manufacturer, handle: handle)
            .run();

        // Should
        result.fold(
          (l) => l.should.be(failure),
          (r) => throw 'Expected left, but got right: $r',
        );
      });
    });
  });
}
