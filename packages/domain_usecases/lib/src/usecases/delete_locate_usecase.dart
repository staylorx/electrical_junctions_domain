import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Deletes a `Locate` from the repository.
class DeleteLocateUseCase {
  final LocateRepository locateRepository;

  DeleteLocateUseCase({required this.locateRepository});

  TaskEither<Failure, Unit> call({required LocateHandle handle}) {
    return locateRepository.deleteByHandle(handle: handle);
  }
}
