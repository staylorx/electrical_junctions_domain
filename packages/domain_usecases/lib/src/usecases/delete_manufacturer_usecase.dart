import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Deletes a `Manufacturer` from the repository.
class DeleteManufacturerUseCase {
  final ManufacturerRepository manufacturerRepository;

  DeleteManufacturerUseCase({required this.manufacturerRepository});

  TaskEither<Failure, Unit> call({required ManufacturerHandle handle}) {
    return manufacturerRepository.delete(handle: handle);
  }
}
