import 'package:equatable/equatable.dart';
import '../value_objects/handles/index.dart';

/// Represents the `Manufacturer` class.
class Manufacturer with EquatableMixin {
  final ManufacturerHandle handle;
  final String name;

  Manufacturer({ManufacturerHandle? handle, String? id, required this.name})
    : handle = handle ?? ManufacturerHandle(id!);

  static final generic = Manufacturer(id: 'generic', name: 'Generic');
  Manufacturer copyWith({
    ManufacturerHandle? handle,
    String? id,
    String? name,
  }) {
    return Manufacturer(handle: handle, id: id, name: name ?? this.name);
  }

  @override
  List<Object?> get props => [handle, name];
}
