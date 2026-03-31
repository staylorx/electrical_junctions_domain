import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Updates an existing `Locate` in the repository.
///
/// Following the UseCase standard, returns LocateWithHandle to provide
/// the handle for UI layer operations.
class UpdateLocateUseCase {
  final LocateRepository locateRepository;

  UpdateLocateUseCase({required this.locateRepository});

  TaskEither<Failure, LocateWithHandle> call({
    required Locate locate,
    required LocateHandle handle,
  }) {
    return locateRepository.update(item: locate, handle: handle);
  }
}
