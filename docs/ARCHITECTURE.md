# Architecture

This package follows **Clean Architecture** (also known as Hexagonal Architecture) principles to maintain clear separation of concerns and allow for flexible infrastructure implementations.

## Layers

### Domain Layer

- **Location**: `packages/domain_entities/`
- **Purpose**: Contains the core business logic and rules
- **Components**:
  - Entities (`Device`, `Circuit`, `DeviceSpecificationModel`, etc.)
  - Value objects (`DeviceHandle`, `UnitOfWork`, etc.)
  - Repository interfaces (abstract contracts)
- **Dependencies**: None (pure Dart, no external packages except `fpdart` and `equatable`)

### Contracts Layer

- **Location**: `packages/domain_contracts/`
- **Purpose**: Defines interfaces between domain and infrastructure layers
- **Components**:
  - Repository contracts (`DeviceRepository`, `CircuitRepository`, etc.)
  - Service contracts for import/export, reporting, handle generation
  - `UnitOfWorkRepository` for transactional operations
- **Dependencies**: Domain entities

### Application Layer

- **Location**: `packages/domain_usecases/`
- **Purpose**: Orchestrates domain operations to fulfill use cases
- **Components**:
  - Use cases (e.g., `CreateDeviceUseCase`, `SearchDevicesUseCase`)
  - Facade pattern for simplified entry point
- **Dependencies**: Domain contracts and entities

### Infrastructure Layer

- **Location**: Not yet implemented in this monorepo (would be in separate packages)
- **Purpose**: Implements repository contracts for specific data sources
- **Examples**:
  - Database implementations (Sembast, SQLite, Hive)
  - File-based implementations (YAML, CSV, Excel)
  - REST API clients
- **Dependencies**: Application layer contracts

## Key Design Patterns

### Single Entity Pattern

All electrical equipment (panels, circuit breakers, switches, transformers, etc.) are represented by a single `Device` entity with type discrimination via `deviceSpecificationType`.

### Facade Pattern

The `ElectricalJunctionsFacade` provides a simplified entry point to the system, hiding complex dependency injection and orchestration details.

### Repository Pattern

Each entity type has a corresponding repository interface that defines CRUD operations. Implementations are provided by the infrastructure layer.

### Unit of Work Pattern

The `UnitOfWork` class encapsulates a transactional boundary, allowing multiple repository operations to be committed or rolled back together. See the [UnitOfWork Guide](UnitOfWork_Guide.md) for details.

## Dependency Direction

```
Infrastructure → Application → Contracts → Domain
```

Dependencies flow inward: outer layers can depend on inner layers, but inner layers never depend on outer layers. This ensures the domain remains independent of infrastructure details.

## Monorepo Structure

```
electrical_junctions_domain/
├── packages/
│   ├── domain_entities/      # Domain layer
│   ├── domain_contracts/     # Contracts layer
│   └── domain_usecases/      # Application layer
└── docs/                     # Documentation
```

## Testing Strategy

- **Domain Layer**: Unit tests for entities and value objects
- **Contracts Layer**: Interface verification tests
- **Application Layer**: Integration tests with mock repositories
- **Infrastructure Layer**: Integration tests with actual data stores
