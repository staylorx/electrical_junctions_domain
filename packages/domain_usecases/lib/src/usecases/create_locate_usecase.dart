import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Creates a new `Locate` and saves it to the repository.
class CreateLocateUseCase {
  final LocateRepository locateRepository;

  CreateLocateUseCase({required this.locateRepository});

  TaskEither<Failure, LocateWithHandle> call({
    required String name,
    Locate? parentLocate,
  }) {
    final locate = Locate(name: name, parentLocate: parentLocate);
    return locateRepository.create(item: locate);
  }
}
