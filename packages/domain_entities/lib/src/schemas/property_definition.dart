import 'property_accessor.dart';

/// Defines a property for a device specification type.
class PropertyDefinition {
  /// The data type of the property.
  final Type type;

  /// Whether this property is required.
  final bool required;

  /// The accessor used to get/set this property.
  final PropertyAccessor<dynamic> accessor;

  /// Optional default value for the property.
  final dynamic defaultValue;

  /// Optional description of what this property represents.
  final String? description;

  PropertyDefinition({
    required this.type,
    this.required = false,
    PropertyAccessor<dynamic>? accessor,
    this.defaultValue,
    this.description,
  }) : accessor =
           accessor ?? MapPropertyAccessor(key: ''); // Will be set by schema

  /// Creates a copy with a specific accessor.
  PropertyDefinition withAccessor(PropertyAccessor<dynamic> newAccessor) {
    return PropertyDefinition(
      type: type,
      required: required,
      accessor: newAccessor,
      defaultValue: defaultValue,
      description: description,
    );
  }
}
