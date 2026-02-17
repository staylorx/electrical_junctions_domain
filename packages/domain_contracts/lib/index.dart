library;

export 'package:electrical_junctions_entities/index.dart';

export 'src/basic_crud_contract.dart';
export 'src/repositories/circuit_repository.dart';
export 'src/repositories/device_repository.dart';
export 'src/repositories/locate_repository.dart';
export 'src/repositories/manufacturer_repository.dart';
export 'src/repositories/device_specification_repository.dart';
export 'src/repositories/device_specification_schema_service.dart';
export 'src/import_validator.dart';
export 'src/unit_of_work_repository.dart';

export 'src/contract_failures.dart';
export 'src/failures/specification_failure.dart';
export 'src/services/handle_generator.dart';
export 'src/services/report_generator_service.dart';
export 'src/services/file_loader.dart';
export 'src/services/yaml_schema_loader.dart';
export 'src/services/csv_export_service.dart';
export 'src/services/yaml_export_service.dart';
export 'src/services/csv_import_service.dart';
export 'src/services/yaml_import_service.dart';

export 'src/staging/staging_facade.dart';
export 'src/staging/repository_access.dart';

export 'src/value_objects/import_result.dart';
export 'src/value_objects/import_pass_criteria.dart';
export 'src/value_objects/mermaid_diagram_data.dart';
export 'src/value_objects/parsing_result.dart';
