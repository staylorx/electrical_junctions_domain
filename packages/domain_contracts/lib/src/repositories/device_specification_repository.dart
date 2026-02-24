import 'package:electrical_junctions_entities/index.dart';
import '../basic_crud_contract.dart';

/// Repository contract for `DeviceSpecification` entities.
/// Provides CRUD operations for device specification catalog data.
abstract class DeviceSpecificationRepository
    implements
        BasicCrudContract<
          DeviceSpecification,
          DeviceSpecificationHandle,
          DeviceSpecificationWithHandle
        > {
  // All CRUD operations inherited from BasicCrudContract
}
