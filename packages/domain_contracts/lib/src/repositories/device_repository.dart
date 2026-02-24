import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';
import '../basic_crud_contract.dart';

/// Repository contract for `Device` entities.
/// Provides CRUD operations and type-based querying for electrical devices.
abstract class DeviceRepository
    implements BasicCrudContract<Device, DeviceHandle, DeviceWithHandle> {
  /// Retrieves all devices of a specific type.
  /// [typeId] is the deviceSpecificationType (e.g., "Panel", "CircuitBreaker").
  TaskEither<Failure, List<DeviceWithHandle>> getDevicesByType(String typeId);
}
