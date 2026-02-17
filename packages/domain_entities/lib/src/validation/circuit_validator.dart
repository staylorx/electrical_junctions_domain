/// Represents the `CircuitValidator` class.
class CircuitValidator {
  /// Validates circuit creation data.
  static List<String> validate({
    String? name,
    required dynamic sourceDevice, // Assuming it's validated separately
    required List<dynamic> connectedDevices,
  }) {
    final errors = <String>[];

    if (name != null && name.isEmpty) {
      errors.add('Circuit name cannot be empty if provided.');
    }

    if (name != null && name.length > 50) {
      errors.add('name cannot exceed 50 characters.');
    }

    // It's acceptable for a circuit to have an empty connected devices list
    // if it has a name (e.g., placeholder or named circuit). Only treat
    // as an error when both name is null/empty and there are no connected devices.
    if ((name == null || name.isEmpty) && connectedDevices.isEmpty) {
      errors.add('Connected devices list cannot be empty.');
    }

    return errors;
  }
}
