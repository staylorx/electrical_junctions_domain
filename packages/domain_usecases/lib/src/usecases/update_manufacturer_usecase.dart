import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Updates an existing `Manufacturer` in the repository.
///
/// Following the UseCase standard, returns ManufacturerWithHandle to provide
/// the handle for UI layer operations.
class UpdateManufacturerUseCase {
  final ManufacturerRepository manufacturerRepository;

  UpdateManufacturerUseCase({required this.manufacturerRepository});

  TaskEither<Failure, ManufacturerWithHandle> call({
    required Manufacturer manufacturer,
    required ManufacturerHandle handle,
  }) {
    return manufacturerRepository.update(item: manufacturer, handle: handle);
  }
}
