import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:electrical_junctions_usecases/index.dart';

// Generate mocks
class MockImportValidator extends Mock implements ImportValidator {}

void main() {
  late ValidateYamlImportUseCase useCase;
  late MockImportValidator mockImportValidator;

  setUp(() {
    mockImportValidator = MockImportValidator();
    useCase = ValidateYamlImportUseCase(validator: mockImportValidator);
  });

  group('Given a ValidateYamlImportUseCase', () {
    final manufacturer = Manufacturer(name: 'Test Mfg');
    final importModel = ImportModel(
      manufacturers: [manufacturer],
      locates: [],
      deviceSpecifications: [],
      devices: [],
      circuits: [],
    );

    group('When validating import model', () {
      test('Then it returns validation issues', () async {
        // Arrange
        final validationResult = ValidationResult([
          ValidationIssue(severity: ValidationSeverity.error, message: 'Error'),
        ]);
        when(
          () => mockImportValidator.validate(importModel),
        ).thenReturn(validationResult);

        // Act
        final result = useCase.call(model: importModel);

        // Should
        expect(result.length, greaterThan(0));
        expect(result.first.isError, isTrue);
      });
    });
  });
}
