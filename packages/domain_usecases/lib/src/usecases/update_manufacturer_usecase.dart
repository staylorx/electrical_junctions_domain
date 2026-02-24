import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Updates an existing `Manufacturer` in the repository.
class UpdateManufacturerUseCase {
  final ManufacturerRepository manufacturerRepository;

  UpdateManufacturerUseCase({required this.manufacturerRepository});

  TaskEither<Failure, Manufacturer> call({
    required Manufacturer manufacturer,
    required ManufacturerHandle handle,
  }) {
    return manufacturerRepository
        .update(item: manufacturer, handle: handle)
        .mapLeft((failure) => failure)
        .map((updated) => updated.manufacturer);
  }
}
