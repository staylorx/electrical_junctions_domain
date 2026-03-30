import 'package:equatable/equatable.dart';
import '../value_objects/handles/device_specification_handle.dart';
import 'manufacturer.dart';

class DeviceSpecificationWithHandle with EquatableMixin {
  final DeviceSpecificationHandle handle;
  final DeviceSpecification deviceSpecification;

  DeviceSpecificationWithHandle({
    required this.handle,
    required this.deviceSpecification,
  });

  DeviceSpecificationWithHandle copyWith({
    DeviceSpecificationHandle? handle,
    DeviceSpecification? deviceSpecification,
  }) {
    return DeviceSpecificationWithHandle(
      handle: handle ?? this.handle,
      deviceSpecification: deviceSpecification ?? this.deviceSpecification,
    );
  }

  @override
  String toString() => deviceSpecification.toString();

  @override
  List<Object?> get props => [handle, deviceSpecification];
}

/// Represents a detailed specification of an electrical device,
/// including its type, model number, manufacturer, and electrical specifications.
class DeviceSpecification with EquatableMixin {
  final String typeId;
  final String modelNumber;
  final Manufacturer manufacturer;
  final Map<String, dynamic> properties;

  /// Creates a new [DeviceSpecification] instance.
  DeviceSpecification({
    required this.typeId,
    required this.modelNumber,
    required this.manufacturer,
    Map<String, dynamic> properties = const {},
  }) : properties = Map<String, dynamic>.from(properties);

  /// Returns a copy of this [DeviceSpecification] with the given fields replaced.
  DeviceSpecification copyWith({
    String? typeId,
    String? modelNumber,
    Manufacturer? manufacturer,
    Map<String, dynamic>? properties,
  }) {
    return DeviceSpecification(
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
  List<Object?> get props => [typeId, manufacturer, modelNumber];
}
