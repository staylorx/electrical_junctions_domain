import 'package:equatable/equatable.dart';
import 'device_specification.dart';
import 'locate.dart';
import '../value_objects/handles/index.dart';

class DeviceWithHandle with EquatableMixin {
  final DeviceHandle handle;
  final Device device;

  DeviceWithHandle({required this.handle, required this.device});

  DeviceWithHandle copyWith({DeviceHandle? handle, Device? device}) {
    return DeviceWithHandle(
      handle: handle ?? this.handle,
      device: device ?? this.device,
    );
  }

  @override
  String toString() => device.name ?? device.deviceSpecification.toString();

  @override
  List<Object?> get props => [handle, device];
}

// Device is an entity representing an electrical device with its core attributes.
// It is an optionally located instance of a DeviceSpecification which defines its type and specifications.
/// Represents the `Device` class.
///
/// Device type is stored on the `DeviceSpecification`.
class Device with EquatableMixin {
  final String? name;
  final DeviceSpecification deviceSpecification;
  final Locate? locate;
  final DeviceHandle? handle;

  Device({
    this.name,
    required this.deviceSpecification,
    this.locate,
    this.handle,
  });

  Device copyWith({
    String? name,
    DeviceSpecification? deviceSpecification,
    Locate? locate,
    DeviceHandle? handle,
  }) {
    return Device(
      name: name ?? this.name,
      deviceSpecification: deviceSpecification ?? this.deviceSpecification,
      locate: locate ?? this.locate,
      handle: handle ?? this.handle,
    );
  }

  @override
  List<Object?> get props => [name, deviceSpecification, locate, handle];
}
