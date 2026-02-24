import 'package:equatable/equatable.dart';
import '../value_objects/handles/index.dart';

class ManufacturerWithHandle with EquatableMixin {
  final ManufacturerHandle handle;
  final Manufacturer manufacturer;

  ManufacturerWithHandle({required this.handle, required this.manufacturer});

  @override
  List<Object?> get props => [handle, manufacturer];
}

/// Represents the `Manufacturer` class.
class Manufacturer with EquatableMixin {
  final ManufacturerHandle handle;
  final String name;

  Manufacturer({required this.handle, required this.name});

  static final generic = Manufacturer(
    handle: ManufacturerHandle('generic'),
    name: 'Generic',
  );
  Manufacturer copyWith({ManufacturerHandle? handle, String? name}) {
    return Manufacturer(handle: handle ?? this.handle, name: name ?? this.name);
  }

  @override
  List<Object?> get props => [handle, name];
}
