import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Updates an existing `Locate` in the repository.
class UpdateLocateUseCase {
  final LocateRepository locateRepository;

  UpdateLocateUseCase({required this.locateRepository});

  TaskEither<Failure, Locate> call({
    required Locate locate,
    required LocateHandle handle,
  }) {
    return locateRepository
        .update(item: locate, handle: handle)
        .mapLeft((failure) => failure)
        .map((updated) => updated.locate);
  }
}
