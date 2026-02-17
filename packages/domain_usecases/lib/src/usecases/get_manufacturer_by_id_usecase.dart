import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Retrieves a `Manufacturer` by id from the repository.
class GetManufacturerByIdUseCase {
  final ManufacturerRepository manufacturerRepository;

  GetManufacturerByIdUseCase({required this.manufacturerRepository});

  TaskEither<Failure, Manufacturer> call({required ManufacturerHandle handle}) {
    return manufacturerRepository.getByHandle(handle: handle);
  }
}
