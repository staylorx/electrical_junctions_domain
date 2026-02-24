import 'package:equatable/equatable.dart';
import '../value_objects/handles/index.dart';

class LocateWithHandle with EquatableMixin {
  final LocateHandle handle;
  final Locate locate;

  LocateWithHandle({required this.handle, required this.locate});

  LocateWithHandle copyWith({LocateHandle? handle, Locate? locate}) {
    return LocateWithHandle(
      handle: handle ?? this.handle,
      locate: locate ?? this.locate,
    );
  }

  @override
  String toString() => locate.toString();

  @override
  List<Object?> get props => [handle, locate];
}

// Locate is an entity representing a physical location with potential hierarchical structure.
// Locates don't necessarily have to be physical places; they can also represent logical groupings.
/// Represents the `Locate` class.
class Locate with EquatableMixin {
  final String name;
  final Locate? parentLocate;

  Locate({required this.name, this.parentLocate});

  Locate copyWith({String? name, Locate? parentLocate}) {
    return Locate(
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
  List<Object?> get props => [name, parentLocate];
}
