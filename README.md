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

### Import from CSV

```dart
final importResult = await facade.importFromCsv(
  path: 'path/to/devices.csv',
  dryRun: false,
).run();

importResult.fold(
  (failure) => print('Import failed: ${failure.message}'),
  (result) => print('Imported: ${result.summary}'),
);
```

### Export to Excel

```dart
final excelBytes = await facade.exportToCsv(
  format: ExportFormat.excel,
  mode: ExportMode.normalized,
).run();

excelBytes.fold(
  (failure) => print('Export failed: ${failure.message}'),
  (bytes) async {
    await File('export.xlsx').writeAsBytes(bytes as List<int>);
    print('Exported to Excel');
  },
);
```

## Architecture

The package follows **Clean Architecture** principles with three main layers:

```
┌─────────────────────────┐
│   Application Layer     │  ← Use Cases, Facade, Templates
│  (Orchestration)        │
└───────────┬─────────────┘
            │ depends on
┌───────────▼─────────────┐
│     Domain Layer        │  ← Entities, Repository Interfaces
│  (Business Logic)       │     Value Objects, Business Rules
└───────────▲─────────────┘
            │ implements
┌───────────┴─────────────┐
│      Data Layer         │  ← DTOs, Repository Implementations
│  (Infrastructure)       │     Database, YAML, CSV Features
└─────────────────────────┘
```

Key principles:

- **Single Entity Pattern**: One `Device` entity for all electrical equipment types
- **Facade Pattern**: `ElectricalJunctionsFacade` provides simplified access
- **Feature-Based Organization**: Data layer organized by feature (database, YAML, CSV)
- **Functional Error Handling**: All operations return `Either<Failure, T>`

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed architecture documentation.

## Core Concepts

### Device

All electrical equipment (panels, circuit breakers, switches, transformers, etc.) are represented by a single `Device` entity:

```dart
final device = Device(
  id: 'panel_1',
  deviceSpecificationType: 'panel',  // Type discrimination
  name: 'Main Panel',
  deviceSpecification: specification,
  locate: location,
);
```

### Circuit

Represents electrical connections between devices:

```dart
final circuit = Circuit(
  id: 'circuit_1',
  name: 'Main Circuit',
  sourceDevice: breaker,
  connectedDevices: [receptacle, switch],
  stereoType: null,  // or 'panel_slot' for panel slots
);
```

### DeviceSpecificationModel

Catalog information for devices:

```dart
final specification = DeviceSpecificationModel(
  id: 'spec_1',
  typeId: 'panel',
  modelNumber: 'PNL-200',
  manufacturer: manufacturer,
  metadata: {'ampRating': 200, 'poleCount': 42},
);
```

## Use Cases

Access through the facade:

**Device Operations**:

- `searchDevices()` - Search for devices by criteria
- `connectDeviceToCircuit()` - Connect device to circuit
- `disconnectDeviceFromCircuit()` - Disconnect device
- `insertDeviceBetweenCircuit()` - Insert device in circuit path

**Circuit Breaker Operations**:

- `installCircuitBreaker()` - Install breaker in panel slot
- `removeCircuitBreaker()` - Remove breaker from slot
- `slotCircuitBreakerIntoPanelSlot()` - Slot breaker into panel

**Panel Operations**:

- `viewPanelStatus()` - Get panel status with all slots
- `createPanelReport()` - Generate panel report

**Import/Export**:

- `importYaml()` - Import from YAML files
- `importFromCsv()` - Import from CSV/Excel files or directories
- `exportToCsv()` - Export to CSV or Excel

**Reporting**:

- `generateDeviceReports()` - Generate markdown reports
- `generateDeviceMermaidDiagram()` - Generate Mermaid diagrams

## Import/Export Formats

### YAML

Human-readable configuration with reference resolution:

```yaml
devices:
  - id: panel_1
    deviceSpecificationType: panel
    deviceSpecification: !ref spec_1
```

### CSV

Spreadsheet format with normalized or denormalized modes:

```csv
id,name,device_spec_id,locate_id
panel_1,Main Panel,spec_1,room_101
```

### Excel

Multi-sheet workbooks with one sheet per entity type.

See [docs/CSV_EXCEL_IMPORT_EXPORT.md](docs/CSV_EXCEL_IMPORT_EXPORT.md) for detailed import/export documentation.

## Testing

```dart
import 'package:electrical_junctions_entities/domain_entities.dart';

void main() {
  test('should search devices', () async {
    // Use in-memory database for testing
    final dbService = SembastDatabaseService();
    final facade = ElectricalJunctionsFacade(dbService);

    // Your test code
  });
}
```

## Documentation

- **[CLAUDE.md](CLAUDE.md)**: Developer guide and coding conventions
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**: Comprehensive architecture documentation
- **[docs/CSV_EXCEL_IMPORT_EXPORT.md](docs/CSV_EXCEL_IMPORT_EXPORT.md)**: CSV/Excel import/export guide
- **[lib/src/application/facade/README.md](lib/src/application/facade/README.md)**: Facade pattern usage
- **Feature READMEs**:
  - [Database](lib/src/data/features/database/README.md)
  - [YAML](lib/src/data/features/yaml/README.md)
  - [CSV](lib/src/data/features/csv/README.md)

## Monorepo Structure

This project uses **Melos** to manage a monorepo with multiple packages:

```
electrical_junctions_domain/
├── packages/
│   └── domain-entities/          # Core domain entities and interfaces
├── applications/
│   ├── base/                      # Base application layer with use cases
│   └── cli_tool/                  # CLI tool for device management
├── melos.yaml                     # Melos configuration
└── pubspec.yaml                   # Workspace root
```

### Packages

- **packages/domain-entities**: Core domain entities, value objects, and repository interfaces (no external dependencies)
- **applications/base**: Application layer with use cases, facades, and data layer implementations
- **applications/cli_tool**: Command-line interface for managing electrical systems

## Development

### Initial Setup

```bash
# Install Melos globally (one-time setup)
dart pub global activate melos

# Bootstrap the monorepo (install dependencies for all packages)
melos bootstrap
```

### Common Commands

```bash
# Run tests across all packages
melos test

# Run tests for a specific package
melos test --scope=electrical_junctions_application
melos test --scope=electrical_junctions_entities

# Analyze all packages
melos analyze

# Format code across all packages
melos format

# Clean all packages
melos clean

# Run a command in all packages
melos exec -- dart pub get

# Run a command in a specific package
melos exec --scope=electrical_junctions_application -- dart test
```

### Package-Specific Commands

```bash
# Work on a specific package
cd applications/base
dart pub get
dart test

# Or use melos from root
melos run test:base
melos run test:entities
```

### Code Analysis and Formatting

```bash
# Analyze all packages
melos analyze

# Format all code
melos format

# Check for formatting issues
melos run format:check
```

## Custom Repository Implementation

Inject custom repository implementations for different data sources:

```dart
class MyRestApiDeviceRepository implements DeviceRepository {
  @override
  Future<Either<Failure, List<Device>>> getAll() async {
    // Your REST API implementation
  }
  // ... implement other methods
}

final config = RepositoryConfig(
  deviceRepository: MyRestApiDeviceRepository(),
  // Other repositories use default database implementations
);

final facade = ElectricalJunctionsFacade(dbService, config: config);
```

## Contributing

1. Follow the architecture guidelines in [CLAUDE.md](CLAUDE.md)
2. Maintain clean architecture boundaries (no upward dependencies)
3. Use functional error handling (`Either<Failure, T>`)
4. Write tests for new features
5. Update documentation

## License

[Your License Here]

## Support

- **Issues**: Report bugs and feature requests on GitHub
- **Documentation**: See [CLAUDE.md](CLAUDE.md) for detailed developer guide
- **Architecture**: See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for system design
