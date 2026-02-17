import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Creates a new `Manufacturer` and saves it to the repository.
class CreateManufacturerUseCase {
  final ManufacturerRepository manufacturerRepository;
  final HandleGenerator _handleGenerator;

  CreateManufacturerUseCase({
    required this.manufacturerRepository,
    required HandleGenerator handleGenerator,
  }) : _handleGenerator = handleGenerator;

  TaskEither<Failure, Manufacturer> call({required String name}) {
    final manufacturer = Manufacturer(
      handle: _handleGenerator.generateManufacturerHandle(),
      name: name,
    );
    return manufacturerRepository
        .create(item: manufacturer)
        .map((_) => manufacturer);
  }
}
