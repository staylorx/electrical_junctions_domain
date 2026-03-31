import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Creates a new `Locate` and saves it to the repository.
///
/// Following the UseCase standard, this accepts:
/// - Simple business parameters for the entity being created (name)
/// - Handles for related persisted entities (parentLocateHandle)
class CreateLocateUseCase {
  final LocateRepository locateRepository;

  CreateLocateUseCase({required this.locateRepository});

  TaskEither<Failure, LocateWithHandle> call({
    required String name,
    LocateHandle? parentLocateHandle,
  }) {
    // If no parent handle, create a locate without parent
    if (parentLocateHandle == null) {
      final locate = Locate(name: name, parentLocate: null);
      return locateRepository.create(item: locate);
    }

    // Fetch the parent locate and then create the new locate
    return locateRepository.getByHandle(handle: parentLocateHandle).flatMap((
      parentLocateWithHandle,
    ) {
      final locate = Locate(
        name: name,
        parentLocate: parentLocateWithHandle.locate,
      );
      return locateRepository.create(item: locate);
    });
  }
}
