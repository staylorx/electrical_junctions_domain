import 'package:equatable/equatable.dart';

/// Domain handle for DeviceSpecification entities.
/// Encapsulates the identity of a DeviceSpecification without exposing infrastructure details.
class DeviceSpecificationHandle with EquatableMixin {
  final String value;

  const DeviceSpecificationHandle(this.value);

  /// Create a handle from a string value (e.g., from database or external source)
  factory DeviceSpecificationHandle.fromString(String value) =>
      DeviceSpecificationHandle(value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
