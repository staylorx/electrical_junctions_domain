import 'package:electrical_junctions_contracts/index.dart';

/// Validates all entities in a [YamlImportModel], returning every issue found.
///
/// This use case depends on an injected validator to perform the validation.
class ValidateYamlImportUseCase {
  final ImportValidator _validator;

  ValidateYamlImportUseCase({required ImportValidator validator})
    : _validator = validator;

  List<ValidationIssue> call({required ImportModel model}) {
    final result = _validator.validate(model);
    return result.issues;
  }
}
