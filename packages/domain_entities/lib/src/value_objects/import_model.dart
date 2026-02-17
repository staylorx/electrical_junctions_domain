import 'package:electrical_junctions_entities/index.dart';
import 'package:equatable/equatable.dart';

/// Pure data container for imported data (CSV, Excel, YAML, etc.).
/// Holds collections of parsed domain entities.
///
/// Behavior (merging, reference resolution) is handled by
/// service implementations in the application layer.
class ImportModel with EquatableMixin {
  final List<Manufacturer> manufacturers;
  final List<Locate> locates;
  final List<DeviceSpecification> deviceSpecifications;
  final List<Device> devices;
  final List<Circuit> circuits;

  ImportModel({
    List<Manufacturer>? manufacturers,
    List<Locate>? locates,
    List<DeviceSpecification>? deviceSpecifications,
    List<Device>? devices,
    List<Circuit>? circuits,
  }) : manufacturers = manufacturers ?? [],
       locates = locates ?? [],
       deviceSpecifications = deviceSpecifications ?? [],
       devices = devices ?? [],
       circuits = circuits ?? [];

  bool get isEmpty =>
      manufacturers.isEmpty &&
      locates.isEmpty &&
      deviceSpecifications.isEmpty &&
      devices.isEmpty &&
      circuits.isEmpty;

  @override
  List<Object?> get props => [
    manufacturers,
    locates,
    deviceSpecifications,
    devices,
    circuits,
  ];
}
