import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';
import '../basic_crud_contract.dart';

/// Repository contract for `Manufacturer` entities.
/// Provides CRUD operations and name-based searching for equipment manufacturers.
abstract class ManufacturerRepository
    implements
        BasicCrudContract<
          Manufacturer,
          ManufacturerHandle,
          ManufacturerWithHandle
        > {
  /// Searches for manufacturers by name (partial match).
  TaskEither<Failure, List<ManufacturerWithHandle>> getManufacturersByName(
    String name,
  );
}
