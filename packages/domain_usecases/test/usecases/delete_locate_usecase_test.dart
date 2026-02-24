import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shouldly/shouldly.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockLocateRepository extends Mock implements LocateRepository {}

void main() {
  late DeleteLocateUseCase useCase;
  late MockLocateRepository mockLocateRepository;

  setUpAll(() {
    registerFallbackValue(LocateHandle('fallback'));
  });

  setUp(() {
    mockLocateRepository = MockLocateRepository();
    useCase = DeleteLocateUseCase(locateRepository: mockLocateRepository);
  });

  group('Given a DeleteLocateUseCase', () {
    group('When executing with valid handle', () {
      test('Then it returns success', () async {
        // Arrange
        final handle = LocateHandle('locate-1');
        when(
          () =>
              mockLocateRepository.deleteByHandle(handle: any(named: 'handle')),
        ).thenReturn(TaskEither.right(unit));

        // Act
        final result = await useCase.call(handle: handle).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (unit) => unit.should.be(unit),
        );
        verify(
          () => mockLocateRepository.deleteByHandle(handle: handle),
        ).called(1);
      });
    });

    group('When entity not found', () {
      test('Then it returns not found failure', () async {
        // Arrange
        final handle = LocateHandle('locate-1');
        final failure = NotFoundFailure('Locate not found');
        when(
          () =>
              mockLocateRepository.deleteByHandle(handle: any(named: 'handle')),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase.call(handle: handle).run();

        // Should
        result.fold(
          (actualFailure) => actualFailure.should.be(failure),
          (_) => fail('Expected failure, got success'),
        );
      });
    });

    group('When repository returns failure', () {
      test('Then it propagates the failure', () async {
        // Arrange
        final handle = LocateHandle('locate-1');
        final failure = DatastoreFailure('Database error');
        when(
          () =>
              mockLocateRepository.deleteByHandle(handle: any(named: 'handle')),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase.call(handle: handle).run();

        // Should
        result.fold(
          (actualFailure) => actualFailure.should.be(failure),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
