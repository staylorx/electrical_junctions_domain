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
}
