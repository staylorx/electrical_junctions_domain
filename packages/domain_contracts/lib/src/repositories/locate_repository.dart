import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';
import '../basic_crud_contract.dart';

/// Repository contract for `Locate` entities.
/// Provides CRUD operations and hierarchical navigation for location entities.
abstract class LocateRepository
    implements BasicCrudContract<Locate, LocateHandle> {
  /// Retrieves all child locations of the specified location.
  TaskEither<Failure, List<Locate>> findChildren(Locate locate);

  /// Retrieves the parent location of the specified location, if any.
  /// Returns null if the location has no parent (is a root location).
  TaskEither<Failure, Locate?> findParent(Locate locate);
}
