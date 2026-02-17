/// Represents the `DeviceValidator` class.
class DeviceValidator {
  /// Validates device creation data.
  static List<String> validate({String? name, int? amperage, int? poles}) {
    final errors = <String>[];

    if (name != null && name.isEmpty) {
      errors.add('Device name cannot be empty if provided.');
    }

    return errors;
  }
}
