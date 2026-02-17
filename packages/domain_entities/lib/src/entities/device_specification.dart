import '../../index.dart';
import 'package:equatable/equatable.dart';

/// Represents a detailed specification of an electrical device,
/// including its type, model number, manufacturer, and electrical specifications.
class DeviceSpecification with EquatableMixin {
  final DeviceSpecificationHandle handle;
  final String typeId;
  final String modelNumber;
  final Manufacturer manufacturer;
  final Map<String, dynamic> properties;

  /// Creates a new [DeviceSpecification] instance.
  DeviceSpecification({
    DeviceSpecificationHandle? handle,
    String? id,
    required this.typeId,
    required this.modelNumber,
    required this.manufacturer,
    Map<String, dynamic> properties = const {},
  }) : handle = handle ?? DeviceSpecificationHandle(id!),
       properties = Map<String, dynamic>.from(properties);

  /// Returns a copy of this [DeviceSpecification] with the given fields replaced.
  DeviceSpecification copyWith({
    DeviceSpecificationHandle? handle,
    String? id,
    String? typeId,
    String? modelNumber,
    Manufacturer? manufacturer,
    Map<String, dynamic>? properties,
  }) {
    return DeviceSpecification(
      handle: handle ?? this.handle,
      typeId: typeId ?? this.typeId,
      modelNumber: modelNumber ?? this.modelNumber,
      manufacturer: manufacturer ?? this.manufacturer,
      properties: properties ?? this.properties,
    );
  }

  /// Safely gets a property value of the specified type.
  /// Returns null if the property doesn't exist or is not of the expected type.
  T? safeGetProperty<T>(String key) {
    final value = properties[key];
    if (value is T) return value;
    return null;
  }

  /// Returns a descriptive string representation of the device specification.
  @override
  String toString() {
    return '$manufacturer $modelNumber';
  }

  @override
  List<Object?> get props => [handle, typeId, manufacturer, modelNumber];
}
