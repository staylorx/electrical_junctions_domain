import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Creates a new `Manufacturer` and saves it to the repository.
class CreateManufacturerUseCase {
  final ManufacturerRepository manufacturerRepository;

  CreateManufacturerUseCase({required this.manufacturerRepository});

  TaskEither<Failure, Manufacturer> call({required String name}) {
    final manufacturer = Manufacturer(name: name);
    return manufacturerRepository
        .create(item: manufacturer)
        .map((withHandle) => withHandle.manufacturer);
  }
}
