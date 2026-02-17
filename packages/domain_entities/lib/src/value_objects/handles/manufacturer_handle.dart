import 'package:equatable/equatable.dart';

/// Domain handle for Manufacturer entities.
/// Encapsulates the identity of a Manufacturer without exposing infrastructure details.
class ManufacturerHandle with EquatableMixin {
  final String value;

  const ManufacturerHandle(this.value);

  /// Create a handle from a string value (e.g., from database or external source)
  factory ManufacturerHandle.fromString(String value) =>
      ManufacturerHandle(value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
