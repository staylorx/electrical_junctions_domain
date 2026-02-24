import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Retrieves a `Locate` by id from the repository.
class GetLocateByIdUseCase {
  final LocateRepository locateRepository;

  GetLocateByIdUseCase({required this.locateRepository});

  TaskEither<Failure, Locate> call({required LocateHandle handle}) {
    return locateRepository
        .getByHandle(handle: handle)
        .mapLeft((failure) => failure)
        .map((result) => result.locate);
  }
}
