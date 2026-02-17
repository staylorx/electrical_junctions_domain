import 'package:electrical_junctions_entities/index.dart';
import 'package:fpdart/fpdart.dart';

/// Basic CRUD operations contract for domain entities.
///
/// Defines the standard create, read, update, delete operations that all
/// repositories must implement. Type parameters:
/// - [T]: The entity type (e.g., Device, Circuit)
/// - [THandle]: The handle type for the entity (e.g., DeviceHandle)
///
/// All operations return TaskEither for functional error handling.
/// Optional [UnitOfWork] parameter supports transactional operations.
abstract class BasicCrudContract<T, THandle> {
  /// Creates a new item in the repository.
  TaskEither<Failure, T> create({required T item, UnitOfWork? txn});

  /// Retrieves all items from the repository.
  TaskEither<Failure, List<T>> getAll();

  /// Retrieves an item by its handle.
  TaskEither<Failure, T> getByHandle({required THandle handle});

  /// Deletes all items from the repository.
  TaskEither<Failure, Unit> deleteAll({UnitOfWork? txn});

  /// Deletes an item by its instance.
  TaskEither<Failure, Unit> deleteByHandle({
    required THandle handle,
    UnitOfWork? txn,
  });

  /// Updates an existing item in the repository.
  TaskEither<Failure, T> update({required T item, UnitOfWork? txn});

  /// Saves an item (create if new, update if exists).
  /// This is a convenience method providing upsert semantics.
  TaskEither<Failure, T> save({required T item, UnitOfWork? txn});

  /// Deletes an item by its handle.
  /// Convenience method that delegates to deleteByHandle.
  TaskEither<Failure, Unit> delete({required THandle handle, UnitOfWork? txn});

  /// Retrieves all items from the repository.
  /// Alias for getAll() to support both naming conventions.
  TaskEither<Failure, List<T>> findAll();
}
