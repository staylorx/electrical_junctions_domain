import 'package:equatable/equatable.dart';
import 'device.dart';
import '../value_objects/handles/index.dart';

class CircuitWithHandle with EquatableMixin {
  final CircuitHandle handle;
  final Circuit circuit;

  CircuitWithHandle({required this.handle, required this.circuit});

  CircuitWithHandle copyWith({CircuitHandle? handle, Circuit? circuit}) {
    return CircuitWithHandle(
      handle: handle ?? this.handle,
      circuit: circuit ?? this.circuit,
    );
  }

  @override
  List<Object?> get props => [handle, circuit];
}

// A circuit is a path from a source device, through intermediate devices, to downstream devices.
// It represents the electrical connection and flow of power.
// It can be as simple as a single circuit breaker feeding a receptacle,
// or more complex with multiple devices in between.
// The more clever version of a circuit is a "panel_slot" circuit,
// where the source device is a panel and the connected devices are fed from specific slots.
/// Represents the `Circuit` class.
class Circuit with EquatableMixin {
  final String? name;
  final Device sourceDevice;
  final List<Device> connectedDevices;
  final String? stereotype; // To distinguish circuit types

  Circuit({
    this.name,
    required this.sourceDevice,
    required this.connectedDevices,
    this.stereotype,
  });

  Circuit copyWith({
    String? name,
    Device? sourceDevice,
    List<Device>? connectedDevices,
    String? stereotype,
  }) {
    return Circuit(
      name: name ?? this.name,
      sourceDevice: sourceDevice ?? this.sourceDevice,
      connectedDevices: connectedDevices ?? this.connectedDevices,
      stereotype: stereotype ?? this.stereotype,
    );
  }

  @override
  List<Object?> get props => [name, sourceDevice, connectedDevices, stereotype];
}
