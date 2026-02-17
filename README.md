# Electrical Junctions Domain

A **Domain-Driven Design (DDD)** Dart package for managing electrical junction systems with support for panels, circuit breakers, circuits, and electrical device configurations.

## Features

- **Clean Architecture**: Hexagonal architecture with clear separation of domain, application, and data layers
- **Multiple Import/Export Formats**: YAML, CSV, and Excel (.xlsx) support  
- **Single Entity Pattern**: Unified device model with type discrimination
- **Functional Error Handling**: Type-safe error handling with `Either<Failure, T>`
- **Facade Pattern**: Simple entry point without complex dependency injection
- **Comprehensive Validation**: Business rule validation with detailed error reporting
- **Report Generation**: Generate markdown reports and Mermaid diagrams

## Quick Start

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  electrical_junctions_domain: ^1.0.0
```

### Basic Usage

```dart
import 'package:electrical_junctions_entities/domain_entities.dart';

void main() async {
  // Create database service
  final dbService = SembastDatabaseService('path/to/database.db');

  // Create facade (single entry point)
  final facade = ElectricalJunctionsFacade(dbService);

  // Search for devices
  final result = await facade.searchDevices(
    deviceSpecificationType: 'panel',
    location: 'Building A',
  ).run();

  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (devices) => print('Found ${devices.length} devices'),
  );

  await facade.close();
}
```

## Architecture Overview

The package follows **Clean Architecture** principles with three main layers:

- **Domain Layer**: Entities, value objects, and repository interfaces
- **Application Layer**: Use cases, facades, and orchestration
- **Data Layer**: Repository implementations for various data sources

See the [architecture documentation](docs/ARCHITECTURE.md) for detailed design.

## Documentation

- **[UnitOfWork Guide](docs/UnitOfWork_Guide.md)**: Guide to UnitOfWork pattern and implementing new data sources
- **[Import/Export Guide](docs/CSV_EXCEL_IMPORT_EXPORT.md)**: CSV/Excel import/export documentation
- **[Architecture Guide](docs/ARCHITECTURE.md)**: Comprehensive architecture documentation

## Development

This project uses **Melos** to manage a monorepo with multiple packages:

```
packages/
├── domain_entities/      # Core domain entities and value objects
├── domain_contracts/     # Repository and service contracts
└── domain_usecases/      # Application use cases
```

### Common Commands

```bash
# Install dependencies
melos bootstrap

# Run tests
melos test

# Analyze code
melos analyze

# Format code
melos format
```

## License

Apache License 2.0

See [LICENSE](LICENSE) file for full text.