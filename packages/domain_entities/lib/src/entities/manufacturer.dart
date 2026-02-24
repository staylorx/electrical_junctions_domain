import 'package:equatable/equatable.dart';
import '../value_objects/handles/index.dart';

class ManufacturerWithHandle with EquatableMixin {
  final ManufacturerHandle handle;
  final Manufacturer manufacturer;

  ManufacturerWithHandle({required this.handle, required this.manufacturer});

  ManufacturerWithHandle copyWith({
    ManufacturerHandle? handle,
    Manufacturer? manufacturer,
  }) {
    return ManufacturerWithHandle(
      handle: handle ?? this.handle,
      manufacturer: manufacturer ?? this.manufacturer,
    );
  }

  @override
  List<Object?> get props => [handle, manufacturer];
}

/// Represents the `Manufacturer` class.
class Manufacturer with EquatableMixin {
  final String name;

  Manufacturer({required this.name});

  Manufacturer copyWith({String? name}) {
    return Manufacturer(name: name ?? this.name);
  }

  @override
  List<Object?> get props => [name];
}
