import 'package:equatable/equatable.dart';
import '../value_objects/handles/index.dart';

// Locate is an entity representing a physical location with potential hierarchical structure.
// Locates don't necessarily have to be physical places; they can also represent logical groupings.
/// Represents the `Locate` class.
class Locate with EquatableMixin {
  final LocateHandle handle;
  final String name;
  final Locate? parentLocate;

  Locate({
    LocateHandle? handle,
    String? id,
    required this.name,
    this.parentLocate,
  }) : handle = handle ?? LocateHandle(id!);

  static final unspecified = Locate(id: 'unspecified', name: 'Unspecified');
  Locate copyWith({
    LocateHandle? handle,
    String? id,
    String? name,
    Locate? parentLocate,
  }) {
    return Locate(
      handle: handle,
      id: id,
      name: name ?? this.name,
      parentLocate: parentLocate ?? this.parentLocate,
    );
  }

  @override
  /// Executes `toString`.
  String toString() {
    if (parentLocate == null) {
      return name;
    } else {
      return '${parentLocate.toString()} > $name';
    }
  }

  @override
  List<Object?> get props => [handle, name, parentLocate];
}
