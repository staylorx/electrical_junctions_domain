import '../entities/device_specification.dart';

/// Represents the `DeviceSpecificationValidator` class.
class DeviceSpecificationValidator {
  /// Validates device specification creation data.
  static List<String> validate({
    required String typeId,
    required String modelNumber,
  }) {
    final errors = <String>[];

    if (typeId.isEmpty) {
      errors.add('Device specification type ID cannot be empty.');
    }

    if (modelNumber.isEmpty) {
      errors.add('Device specification model number cannot be empty.');
    }

    return errors;
  }

  /// Validates uniqueness of a device specification against a list of existing specs.
  /// Returns errors if the specification already exists in the list.
  static List<String> validateUnique({
    required String typeId,
    required String modelNumber,
    required List<DeviceSpecification> existingSpecs,
  }) {
    final errors = <String>[];

    // Check if a spec with the same typeId and modelNumber already exists
    final duplicate = existingSpecs.any(
      (spec) => spec.typeId == typeId && spec.modelNumber == modelNumber,
    );

    if (duplicate) {
      errors.add(
        'Device specification with type ID "$typeId" and model number "$modelNumber" already exists.',
      );
    }

    return errors;
  }

  /// Combines basic validation and uniqueness check.
  static List<String> validateWithUniqueness({
    required String typeId,
    required String modelNumber,
    required List<DeviceSpecification> existingSpecs,
  }) {
    final errors = <String>[];
    errors.addAll(validate(typeId: typeId, modelNumber: modelNumber));
    errors.addAll(
      validateUnique(
        typeId: typeId,
        modelNumber: modelNumber,
        existingSpecs: existingSpecs,
      ),
    );
    return errors;
  }
}
