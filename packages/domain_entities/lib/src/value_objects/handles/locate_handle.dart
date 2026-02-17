import 'package:equatable/equatable.dart';

/// Domain handle for Locate entities.
/// Encapsulates the identity of a Locate without exposing infrastructure details.
class LocateHandle with EquatableMixin {
  final String value;

  const LocateHandle(this.value);

  /// Create a handle from a string value (e.g., from database or external source)
  factory LocateHandle.fromString(String value) => LocateHandle(value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
