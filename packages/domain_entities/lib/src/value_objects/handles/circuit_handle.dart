import 'package:equatable/equatable.dart';

/// Domain handle for Circuit entities.
/// Encapsulates the identity of a Circuit without exposing infrastructure details.
class CircuitHandle with EquatableMixin {
  final String value;

  const CircuitHandle(this.value);

  /// Create a handle from a string value (e.g., from database or external source)
  factory CircuitHandle.fromString(String value) => CircuitHandle(value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
