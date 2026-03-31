import '../entities/manufacturer.dart';

/// Represents the `ManufacturerValidator` class.
class ManufacturerValidator {
  /// Validates manufacturer creation data.
  static List<String> validate({required String name}) {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('Manufacturer name cannot be empty.');
    }

    if (name.length > 100) {
      errors.add('Manufacturer name cannot exceed 100 characters.');
    }

    return errors;
  }

  /// Validates uniqueness of a manufacturer against a list of existing manufacturers.
  /// Returns errors if a manufacturer with the same name already exists.
  static List<String> validateUnique({
    required String name,
    required List<Manufacturer> existingManufacturers,
  }) {
    final errors = <String>[];

    // Check if a manufacturer with the same name already exists
    final duplicate = existingManufacturers.any(
      (manufacturer) => manufacturer.name == name,
    );

    if (duplicate) {
      errors.add('Manufacturer with name "$name" already exists.');
    }

    return errors;
  }

  /// Combines basic validation and uniqueness check.
  static List<String> validateWithUniqueness({
    required String name,
    required List<Manufacturer> existingManufacturers,
  }) {
    final errors = <String>[];
    errors.addAll(validate(name: name));
    errors.addAll(
      validateUnique(name: name, existingManufacturers: existingManufacturers),
    );
    return errors;
  }
}
