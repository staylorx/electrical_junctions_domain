/// Abstract base class for accessing properties in a type-safe way.
abstract class PropertyAccessor<T> {
  /// Gets a property value from the given properties map.
  T? get(Map<String, dynamic> properties);

  /// Sets a property value in the given properties map.
  void set(Map<String, dynamic> properties, T? value);
}

/// Default implementation that accesses properties directly from a Map.
class MapPropertyAccessor<T> implements PropertyAccessor<T> {
  /// The key to use for accessing the property in the map.
  final String key;

  MapPropertyAccessor({required this.key});

  @override
  T? get(Map<String, dynamic> properties) {
    final value = properties[key];
    return value as T?;
  }

  @override
  void set(Map<String, dynamic> properties, T? value) {
    if (value == null) {
      properties.remove(key);
    } else {
      properties[key] = value;
    }
  }
}
