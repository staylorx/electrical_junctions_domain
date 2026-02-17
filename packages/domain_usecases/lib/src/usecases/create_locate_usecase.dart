import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Creates a new `Locate` and saves it to the repository.
class CreateLocateUseCase {
  final LocateRepository locateRepository;
  final HandleGenerator _handleGenerator;

  CreateLocateUseCase({
    required this.locateRepository,
    required HandleGenerator handleGenerator,
  }) : _handleGenerator = handleGenerator;

  TaskEither<Failure, Locate> call({required String name}) {
    final locate = Locate(
      handle: _handleGenerator.generateLocateHandle(),
      name: name,
    );
    return locateRepository.create(item: locate);
  }
}
