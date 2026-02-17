import 'property_accessor.dart';
import 'property_definition.dart';

/// Pure data representation of a device specification schema.
/// Defines the structure and properties for a device type.
///
/// Behavior (validation, accessor retrieval) is handled by
/// IDeviceSpecificationSchemaService implementations.
class DeviceSpecificationSchema {
  /// The device specification type id this schema defines.
  final String typeId;

  /// Map of property names to their definitions.
  final Map<String, PropertyDefinition> properties;

  DeviceSpecificationSchema(
    this.typeId,
    Map<String, PropertyDefinition> properties,
  ) : properties = _initializeProperties(properties);

  static Map<String, PropertyDefinition> _initializeProperties(
    Map<String, PropertyDefinition> inputProperties,
  ) {
    final result = Map<String, PropertyDefinition>.from(inputProperties);

    // Set up accessors for each property
    for (final entry in result.entries) {
      final definition = entry.value;
      final accessor = MapPropertyAccessor(key: entry.key);
      result[entry.key] = definition.withAccessor(accessor);
    }

    return result;
  }

  /// Gets all property names defined in this schema.
  List<String> getPropertyNames() => properties.keys.toList();

  /// Gets all required property names.
  List<String> getRequiredPropertyNames() => properties.entries
      .where((entry) => entry.value.required)
      .map((entry) => entry.key)
      .toList();
}
