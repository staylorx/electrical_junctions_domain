import '../entities/locate.dart';

/// Represents the `LocateValidator` class.
class LocateValidator {
  /// Validates locate creation data.
  static List<String> validate({required String name}) {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('Locate name cannot be empty.');
    }

    if (name.length > 100) {
      errors.add('Locate name cannot exceed 100 characters.');
    }

    return errors;
  }

  /// Validates uniqueness of a locate against a list of existing locates.
  /// Returns errors if a locate with the same name already exists.
  static List<String> validateUnique({
    required String name,
    required List<Locate> existingLocates,
  }) {
    final errors = <String>[];

    // Check if a locate with the same name already exists
    final duplicate = existingLocates.any((locate) => locate.name == name);

    if (duplicate) {
      errors.add('Locate with name "$name" already exists.');
    }

    return errors;
  }

  /// Combines basic validation and uniqueness check.
  static List<String> validateWithUniqueness({
    required String name,
    required List<Locate> existingLocates,
  }) {
    final errors = <String>[];
    errors.addAll(validate(name: name));
    errors.addAll(validateUnique(name: name, existingLocates: existingLocates));
    return errors;
  }
}
