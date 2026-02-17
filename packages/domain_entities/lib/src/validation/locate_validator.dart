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
}
