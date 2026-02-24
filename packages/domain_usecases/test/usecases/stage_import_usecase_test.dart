import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';

// Generate mocks
class MockImportValidator extends Mock implements ImportValidator {}

void main() {
  late StageImportUseCase useCase;
  late MockImportValidator mockImportValidator;

  setUp(() {
    mockImportValidator = MockImportValidator();
    useCase = StageImportUseCase(entityValidator: mockImportValidator);
  });

  group('Given a StageImportUseCase', () {
    final manufacturer = Manufacturer(name: 'Test Mfg');
    final importModel = ImportModel(
      manufacturers: [manufacturer],
      locates: [],
      deviceSpecifications: [],
      devices: [],
      circuits: [],
    );
    final parsingResult = ParsingResult(model: importModel, issues: []);

    group('When staging import successfully', () {
      test('Then it returns import result with staged data', () async {
        // Arrange
        final validationResult = ValidationResult.success;
        when(
          () => mockImportValidator.validate(importModel),
        ).thenReturn(validationResult);

        // Act
        final result = await useCase.call(parsingResult).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (importResult) => expect(
            importResult.importModel.manufacturers,
            contains(manufacturer),
          ),
        );
      });
    });

    group('When validation has issues', () {
      test('Then it includes issues in result', () async {
        // Arrange
        final validationResult = ValidationResult([
          ValidationIssue(severity: ValidationSeverity.error, message: 'Error'),
        ]);
        when(
          () => mockImportValidator.validate(importModel),
        ).thenReturn(validationResult);

        // Act
        final result = await useCase.call(parsingResult).run();

        // Should
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (importResult) => expect(importResult.issues.length, greaterThan(0)),
        );
      });
    });
  });
}
