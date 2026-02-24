import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';

/// Basic CRUD operations contract for domain entities.
///
/// Defines the standard create, read, update, delete operations that all
/// repositories must implement. Type parameters:
/// - [T]: The entity type (e.g., Device, Circuit)
/// - [TH]: The handle type for the entity (e.g., DeviceHandle)
/// - [TWH]: The entity type with handle (e.g., DeviceWithHandle)
///
/// All operations return TaskEither for functional error handling.
/// Optional [UnitOfWork] parameter supports transactional operations.
abstract class BasicCrudContract<T, TH, TWH> {
  /// Creates a new item in the repository.
  TaskEither<Failure, TWH> create({required T item, UnitOfWork? unitOfWork});

  /// Retrieves all items from the repository.
  TaskEither<Failure, List<TWH>> getAll();

  /// Retrieves an item by its handle.
  TaskEither<Failure, TWH> getByHandle({required TH handle});

  /// Deletes all items from the repository.
  TaskEither<Failure, Unit> deleteAll({UnitOfWork? unitOfWork});

  /// Deletes an item by its instance.
  TaskEither<Failure, Unit> deleteByHandle({
    required TH handle,
    UnitOfWork? unitOfWork,
  });

  /// Updates an existing item in the repository.
  TaskEither<Failure, TWH> update({
    required T item,
    required TH handle,
    UnitOfWork? unitOfWork,
  });

  /// Deletes an item by its handle.
  /// Convenience method that delegates to deleteByHandle.
  TaskEither<Failure, Unit> delete({
    required TH handle,
    UnitOfWork? unitOfWork,
  });
}
