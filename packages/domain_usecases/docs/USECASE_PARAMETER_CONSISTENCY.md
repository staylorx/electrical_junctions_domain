# UseCase Parameter Consistency Standard

This document defines the standard patterns for ALL UseCase method signatures across the domain layer.
All usecases assume they can be called from the UI layer and should provide handles for subsequent operations.

## Core Principles

All usecases must follow consistent patterns to ensure:
- Clear separation between data being modified and data being referenced
- Type safety through the use of handles for persisted entity references
- UI layer always has access to handles for subsequent operations
- Predictable and discoverable API design
- Removal of redundant wrapper usecases that provide no business logic

## Rule 1: CREATE Usecases

### Parameters
- Accept **simple business parameters** for the entity being created (e.g., `String name`, `String typeId`, etc.)
- Accept **handles** ONLY for related entities that are already persisted
  - Use the entity's Handle type (e.g., `LocateHandle`, `ManufacturerHandle`)
  - Never pass full entity objects for related entities
  - Make these parameters optional if the relationship is optional
- **DO NOT** accept full objects for the entity being created—construct it from parameters

### Return Type
- Return `EntityWithHandle` to provide both the entity data and its handle
- This ensures the UI layer can perform subsequent operations with the returned handle

### Example

```dart
class CreateLocateUseCase {
  TaskEither<Failure, LocateWithHandle> call({
    required String name,
    LocateHandle? parentLocateHandle,  // Use Handle for related entity
  }) {
    final locate = Locate(
      name: name,
      parentLocate: null,  // Will fetch parent if handle is provided
    );
    return locateRepository.create(item: locate);
  }
}
```

## Rule 2: UPDATE Usecases

### Parameters
- Accept a **full object** of the entity being updated
  - This represents the desired state after the update
- Accept a **handle** to identify which record to update in the repository
- **DO NOT** accept simple parameters (e.g., don't accept `String? newName` + `String? newValue`)
  - Pass the modified entity object instead

### Return Type
- Return `EntityWithHandle` for consistency with CREATE
- This provides the updated entity and its handle for UI layer operations

### Example

```dart
class UpdateLocateUseCase {
  TaskEither<Failure, LocateWithHandle> call({
    required Locate locate,
    required LocateHandle handle,
  }) {
    return locateRepository.update(item: locate, handle: handle);
  }
}
```

## Rule 3: DELETE Usecases

### Parameters
- Accept only a **handle** to identify which record to delete
- Use the entity's Handle type for type safety

### Example

```dart
class DeleteLocateUseCase {
  TaskEither<Failure, Unit> call({
    required LocateHandle handle,
  }) {
    return locateRepository.delete(handle: handle);
  }
}
```

## Rule 4: QUERY/READ Usecases

### Parameters
- Accept **handles** (not full objects) for related entities to filter by
- Accept **simple identifiers** (not objects) for search criteria
- Use handles to identify the primary entity being viewed/queried

### Return Type (Updated Standard)
- **View Usecases** (e.g., ViewCircuitDetailsUseCase, ViewPanelStatusUseCase): Return `EntityWithHandle` 
  - This provides handles for UI to perform subsequent operations
- **Search/List Usecases** (e.g., SearchDevicesUseCase): Return `List<Entity>` (unwrapped)
  - Handles not needed for search results (but if UI needs them later, it fetches by ID)
- **Property Access Usecases**: Specialized return types as appropriate

### Anti-Pattern: Redundant Wrapper Usecases
- **REMOVED**: GetDeviceByIdUseCase, GetLocateByIdUseCase, GetManufacturerByIdUseCase, GetDeviceSpecificationByIdUseCase, GetCircuitUseCase
- **Reason**: These were thin wrappers that only called `repository.getByHandle()` and unwrapped the result
- **Alternative**: Use semantic view usecases (ViewCircuitDetailsUseCase, ViewPanelStatusUseCase) or call repository directly

## Anti-Patterns

❌ **DO NOT** do this:

```dart
// ❌ Mixing object and simple parameters for the entity being created
TaskEither<Failure, Device> call({
  String? name,
  DeviceSpecification spec,  // Object for new entity
  Locate locate,              // Object for new entity
})

// ❌ Passing full objects for related entities in CREATE
TaskEither<Failure, LocateWithHandle> call({
  required String name,
  Locate parentLocate,  // ❌ Should be LocateHandle
})

// ❌ Simple parameters for UPDATE instead of full object
TaskEither<Failure, Manufacturer> call({
  required String newName,
  required ManufacturerHandle handle,
})

// ❌ Returning unwrapped entity from UPDATE
TaskEither<Failure, Locate> call({  // ❌ Should return LocateWithHandle
  required Locate locate,
  required LocateHandle handle,
})
```

## Migration Guide

If your usecase doesn't follow these rules, here's how to migrate:

### CREATE: Converting Objects to Handles

**Before:**
```dart
TaskEither<Failure, LocateWithHandle> call({
  required String name,
  Locate? parentLocate,  // ❌ Full object
})
```

**After:**
```dart
TaskEither<Failure, LocateWithHandle> call({
  required String name,
  LocateHandle? parentLocateHandle,  // ✓ Handle instead
})
```

### UPDATE: Converting Simple Parameters to Object

**Before:**
```dart
TaskEither<Failure, Device> call({
  String? name,
  DeviceSpecification deviceSpecification,
  Locate? locate,
  required DeviceHandle handle,
})
```

**After:**
```dart
TaskEither<Failure, DeviceWithHandle> call({
  required Device device,
  required DeviceHandle handle,
})
```

Callers should construct the updated Device object before calling the usecase:

```dart
final updatedDevice = existingDevice.copyWith(
  name: newName,
  specification: newSpec,
);
return updateDeviceUseCase(device: updatedDevice, handle: handle);
```

### UPDATE: Adding Handles to Return Types

**Before:**
```dart
TaskEither<Failure, Locate> call({
  required Locate locate,
  required LocateHandle handle,
})
```

**After:**
```dart
TaskEither<Failure, LocateWithHandle> call({
  required Locate locate,
  required LocateHandle handle,
})
```

Update the method body to return the full WithHandle result:

```dart
return locateRepository.update(item: locate, handle: handle);
```

## Implementation Summary

### Phases Completed

1. **Phase 1**: Removed 5 redundant getById wrapper usecases
   - GetDeviceByIdUseCase, GetLocateByIdUseCase, GetManufacturerByIdUseCase, GetDeviceSpecificationByIdUseCase, GetCircuitUseCase
   
2. **Phase 2**: Updated view usecases to return WithHandle
   - ViewCircuitDetailsUseCase now returns CircuitWithHandle
   - ViewPanelStatusUseCase now returns DeviceWithHandle

3. **Phase 3**: Fixed circuit manipulation usecases to accept handles
   - ConnectDeviceToCircuitUseCase: accepts DeviceHandle instead of Device
   - DisconnectDeviceFromCircuitUseCase: accepts DeviceHandle instead of Device
   - InsertDeviceBetweenCircuitUseCase: accepts DeviceHandles instead of Device objects
   - SlotCircuitBreakerIntoPanelSlotUseCase: accepts DeviceHandles instead of Device objects

4. **Phase 4**: Fixed query usecases for consistency
   - SearchDevicesUseCase: accepts ManufacturerHandle and LocateHandle instead of objects
   - SetDeviceSpecificationPropertyUseCase: now returns DeviceSpecificationWithHandle

## Benefits of This Standard

1. **Consistency**: All usecases follow the same pattern, reducing cognitive load
2. **Type Safety**: Handles prevent invalid references to non-persisted entities
3. **Clear Semantics**: Parameters clearly indicate what's being created/updated vs. referenced
4. **UI Integration**: UI always gets handles for state management and navigation
5. **Testability**: Handles are easier to mock than full objects
6. **Maintainability**: Future developers can quickly understand expected parameter types
7. **Refactoring Safety**: Compile-time checks catch misuse of parameters
8. **Reduced Duplication**: No more thin wrapper usecases that add no business value
