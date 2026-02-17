import 'package:equatable/equatable.dart';

import '../../index.dart';

/// Defines a device type with inheritance capabilities
class DeviceTypeDefinition with EquatableMixin {
  /// The unique name of the device type
  final String name;

  /// The parent type this type extends (null for root types)
  final String? parentType;

  /// Optional description of what this device type represents
  final String? description;

  /// Properties defined specifically for this type
  final Map<String, PropertyDefinition> properties;

  /// Creates a new device type definition
  DeviceTypeDefinition({
    required this.name,
    this.parentType,
    this.description,
    required this.properties,
  });

  /// Whether this is a root type (no parent)
  bool get isRoot => parentType == null;

  @override
  List<Object?> get props => [name, parentType, description, properties];
}
