# Domain Contracts

This package defines the interfaces (contracts) that connect the domain layer with the infrastructure layer. It includes:

- **Repository contracts** (`DeviceRepository`, `CircuitRepository`, etc.) that extend `BasicCrudContract`.
- **Service contracts** for import/export, reporting, and handle generation.
- **UnitOfWork abstraction** for transactional operations.

## Key Concepts

### UnitOfWork and Transaction Handles

The `UnitOfWork` pattern represents a transactional boundary. In this package, `UnitOfWork` is a generic value object that can carry an infrastructure‑specific **transaction handle** (e.g., a Sembast database transaction, a SQL connection, a Hive box).

**Important:** The transaction handle inside a `UnitOfWork` is **not** the same as the entity handles (`DeviceHandle`, `CircuitHandle`, etc.) used in CRUD operations. Entity handles identify domain entities; transaction handles identify infrastructure‑level transactions.

For a comprehensive guide on how `UnitOfWork` works, how to implement it for new data sources, and how to avoid common pitfalls, see the [UnitOfWork Guide](../../docs/UnitOfWork_Guide.md).

### BasicCrudContract

All repository contracts extend `BasicCrudContract<T, THandle>`, which provides standard create, read, update, and delete operations. Each method accepts an optional `UnitOfWork?` parameter that allows the operation to participate in an ongoing transaction.

Example:
```dart
TaskEither<Failure, Device> create({
  required Device item,
  UnitOfWork? unitOfWork,
});
```

If a `unitOfWork` is provided, the repository implementation should use the attached transaction handle to perform the operation within that transaction. If `unitOfWork` is `null`, the operation may run outside a transaction (auto‑commit) or use a default transaction strategy.

### UnitOfWorkRepository

The `UnitOfWorkRepository` abstract class provides infrastructure‑side management of an active transaction:

```dart
abstract class UnitOfWorkRepository {
  UnitOfWork get currentUnitOfWork;
  Future<void> saveChanges();
  Future<void> discardChanges();
}
```

Implementations are responsible for creating transaction handles, attaching them to `UnitOfWork` instances, and committing or rolling back when `saveChanges()` or `discardChanges()` is called.

## Implementing a New Data Source

To add support for a new persistence technology (e.g., Hive, SQLite, a REST API):

1. Define the transaction handle type (e.g., `Box` for Hive).
2. Implement `UnitOfWorkRepository` for that technology.
3. Implement each repository contract using the technology’s API, respecting the `unitOfWork` parameter.
4. Wire up your implementations in the application’s composition root (e.g., the `ElectricalJunctionsFacade`).

Detailed step‑by‑step instructions and code examples are available in the [UnitOfWork Guide](../../docs/UnitOfWork_Guide.md).

## Testing

Repository and service contracts are verified by the tests in `test/contracts/`. These tests ensure that concrete implementations satisfy the contract’s semantics.

When writing your own implementations, you can reuse these contract tests by extending them with your concrete repository classes.

## Further Reading

- [Domain-Driven Design](https://domainlanguage.com/ddd/) by Eric Evans
- [Unit of Work Pattern](https://martinfowler.com/eaaCatalog/unitOfWork.html) (Martin Fowler)
- The [UnitOfWork Guide](../../docs/UnitOfWork_Guide.md) in this repository.