import 'package:equatable/equatable.dart';

/// Domain handle for Device entities.
/// Encapsulates the identity of a Device without exposing infrastructure details.
class DeviceHandle with EquatableMixin {
  final String value;

  const DeviceHandle(this.value);

  /// Create a handle from a string value (e.g., from database or external source)
  factory DeviceHandle.fromString(String value) => DeviceHandle(value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
