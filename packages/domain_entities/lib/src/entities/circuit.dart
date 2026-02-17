import 'package:equatable/equatable.dart';
import 'device.dart';
import '../value_objects/handles/index.dart';

// A circuit is a path from a source device, through intermediate devices, to downstream devices.
// It represents the electrical connection and flow of power.
// It can be as simple as a single circuit breaker feeding a receptacle,
// or more complex with multiple devices in between.
// The more clever version of a circuit is a "panel_slot" circuit,
// where the source device is a panel and the connected devices are fed from specific slots.
/// Represents the `Circuit` class.
class Circuit with EquatableMixin {
  final CircuitHandle handle;
  final String? name;
  final Device sourceDevice;
  final List<Device> connectedDevices;
  final String? stereoType; // To distinguish circuit types

  Circuit({
    required this.handle,
    this.name,
    required this.sourceDevice,
    required this.connectedDevices,
    this.stereoType,
  });

  Circuit copyWith({
    CircuitHandle? handle,
    String? name,
    Device? sourceDevice,
    List<Device>? connectedDevices,
    String? stereoType,
  }) {
    return Circuit(
      handle: handle ?? this.handle,
      name: name ?? this.name,
      sourceDevice: sourceDevice ?? this.sourceDevice,
      connectedDevices: connectedDevices ?? this.connectedDevices,
      stereoType: stereoType ?? this.stereoType,
    );
  }

  @override
  List<Object?> get props => [
    handle,
    name,
    sourceDevice,
    connectedDevices,
    stereoType,
  ];
}
