import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockLocateRepository extends Mock implements LocateRepository {}

void main() {
  late MockLocateRepository mockLocateRepository;
  late CreateLocateUseCase useCase;

  setUpAll(() {
    registerFallbackValue(Locate(name: 'fallback'));
    mockLocateRepository = MockLocateRepository();
    useCase = CreateLocateUseCase(locateRepository: mockLocateRepository);
  });

  group('Given a CreateLocateUseCase', () {
    group('When executing with valid input', () {
      test('Then it returns success with expected data', () async {
        // Arrange
        final name = 'Room 101';
        final expected = LocateWithHandle(
          handle: LocateHandle('locate-1'),
          locate: Locate(name: name),
        );
        when(
          () => mockLocateRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.right(expected));

        // Act
        final result = await useCase.call(name: name).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (locateWithHandle) => expect(locateWithHandle, equals(expected)),
        );
        verify(
          () => mockLocateRepository.create(item: any(named: 'item')),
        ).called(1);
      });
    });

    group('When executing with optional parent parameter', () {
      test('Then it passes parent to the locate entity', () async {
        // Arrange
        final name = 'Room 102';
        final parentLocate = Locate(name: 'Building A');
        final expected = LocateWithHandle(
          handle: LocateHandle('locate-2'),
          locate: Locate(name: name, parentLocate: parentLocate),
        );
        when(
          () => mockLocateRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.right(expected));

        // Act
        final result = await useCase
            .call(name: name, parentLocate: parentLocate)
            .run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (locateWithHandle) => expect(locateWithHandle, equals(expected)),
        );
        verify(
          () => mockLocateRepository.create(item: any(named: 'item')),
        ).called(1);
      });
    });

    group('When repository returns failure', () {
      test('Then it propagates the failure', () async {
        // Arrange
        final failure = DatastoreFailure('Database error');
        when(
          () => mockLocateRepository.create(item: any(named: 'item')),
        ).thenReturn(TaskEither.left(failure));

        // Act
        final result = await useCase.call(name: 'Room 101').run();

        // Should
        result.fold(
          (actualFailure) => expect(actualFailure, equals(failure)),
          (_) => fail('Expected failure, got success'),
        );
      });
    });
  });
}
