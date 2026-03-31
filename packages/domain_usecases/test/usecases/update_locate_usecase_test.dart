import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shouldly/shouldly.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockLocateRepository extends Mock implements LocateRepository {}

void main() {
  late UpdateLocateUseCase useCase;
  late MockLocateRepository mockLocateRepository;

  setUpAll(() {
    registerFallbackValue(Locate(name: 'fallback'));
    registerFallbackValue(LocateHandle('fallback'));
  });

  setUp(() {
    mockLocateRepository = MockLocateRepository();
    useCase = UpdateLocateUseCase(locateRepository: mockLocateRepository);
  });

  group('Given a UpdateLocateUseCase', () {
    final handle = LocateHandle('locate-123');
    final locate = Locate(name: 'Test Location');

    group('When executing with valid input', () {
      test('Then it returns success with updated locate', () async {
        // Arrange
        final updatedLocate = Locate(name: 'Updated Location');
        final locateWithHandle = LocateWithHandle(
          handle: handle,
          locate: updatedLocate,
        );
        when(
          () => mockLocateRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(locateWithHandle));

        // Act
        final result = await useCase.call(locate: locate, handle: handle).run();

        // Should
        result.fold(
          (l) => throw 'Expected right, but got left: $l',
          (r) => r.should.be(locateWithHandle),
        );
        verify(
          () => mockLocateRepository.update(item: locate, handle: handle),
        ).called(1);
      });
    });

    group('When entity not found', () {
      test('Then it returns not found failure', () async {
        // Arrange
        final failure = NotFoundFailure('Locate not found');
        when(
          () => mockLocateRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase.call(locate: locate, handle: handle).run();

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
          () => mockLocateRepository.update(
            item: any(named: 'item'),
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase.call(locate: locate, handle: handle).run();

        // Should
        result.fold(
          (l) => l.should.be(failure),
          (r) => throw 'Expected left, but got right: $r',
        );
      });
    });
  });
}
