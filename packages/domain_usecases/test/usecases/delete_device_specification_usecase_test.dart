import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shouldly/shouldly.dart';
import 'package:electrical_junctions_usecases/index.dart';
import 'package:fpdart/fpdart.dart';

// Generate mocks
class MockDeviceSpecificationRepository extends Mock
    implements DeviceSpecificationRepository {}

void main() {
  late DeleteDeviceSpecificationUseCase useCase;
  late MockDeviceSpecificationRepository mockDeviceSpecificationRepository;

  setUpAll(() {
    registerFallbackValue(DeviceSpecificationHandle('fallback'));
  });

  setUp(() {
    mockDeviceSpecificationRepository = MockDeviceSpecificationRepository();
    useCase = DeleteDeviceSpecificationUseCase(
      deviceSpecificationRepository: mockDeviceSpecificationRepository,
    );
  });

  group('Given a DeleteDeviceSpecificationUseCase', () {
    group('When executing with valid handle', () {
      test('Then it returns success', () async {
        // Arrange
        final handle = DeviceSpecificationHandle('device-spec-1');
        when(
          () => mockDeviceSpecificationRepository.delete(
            handle: any(named: 'handle'),
          ),
        ).thenReturn(TaskEither.right(unit));

        // Act
        final result = await useCase.call(handle: handle).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (unit) => unit.should.be(unit),
        );
        verify(
          () => mockDeviceSpecificationRepository.delete(handle: handle),
        ).called(1);
      });
    });

    group('When entity not found', () {
      test('Then it returns not found failure', () async {
        // Arrange
        final handle = DeviceSpecificationHandle('device-spec-1');
        final failure = NotFoundFailure('Device specification not found');
        when(
          () => mockDeviceSpecificationRepository.delete(
            handle: any(named: 'handle'),
          ),
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
        final handle = DeviceSpecificationHandle('device-spec-1');
        final failure = DatastoreFailure('Database error');
        when(
          () => mockDeviceSpecificationRepository.delete(
            handle: any(named: 'handle'),
          ),
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
