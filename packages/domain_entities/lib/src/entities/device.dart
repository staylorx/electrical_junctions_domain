import 'package:equatable/equatable.dart';
import 'device_specification.dart';
import 'locate.dart';
import '../value_objects/handles/index.dart';

// Device is an entity representing an electrical device with its core attributes.
// It is an optionally located instance of a DeviceSpecification which defines its type and specifications.
/// Represents the `Device` class.
///
/// Device type is stored on the `DeviceSpecification`.
class Device with EquatableMixin {
  final DeviceHandle handle;
  final String? name;
  final DeviceSpecification deviceSpecification;
  final Locate? locate;

  Device({
    DeviceHandle? handle,
    String? id,
    this.name,
    required this.deviceSpecification,
    this.locate,
  }) : handle = handle ?? DeviceHandle(id!);

  Device copyWith({
    DeviceHandle? handle,
    String? id,
    String? name,
    DeviceSpecification? deviceSpecification,
    Locate? locate,
  }) {
    return Device(
      handle: handle ?? this.handle,
      name: name ?? this.name,
      deviceSpecification: deviceSpecification ?? this.deviceSpecification,
      locate: locate ?? this.locate,
    );
  }

  @override
  List<Object?> get props => [handle, name, deviceSpecification, locate];
}
