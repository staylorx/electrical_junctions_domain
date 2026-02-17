import 'package:electrical_junctions_contracts/index.dart';

/// Provides access to all repository instances.
class RepositoryAccess {
  final DeviceRepository device;
  final LocateRepository locate;
  final CircuitRepository circuit;
  final ManufacturerRepository manufacturer;
  final DeviceSpecificationRepository deviceSpecification;

  const RepositoryAccess({
    required this.device,
    required this.locate,
    required this.circuit,
    required this.manufacturer,
    required this.deviceSpecification,
  });
}
