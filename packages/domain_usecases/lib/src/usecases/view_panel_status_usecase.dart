import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for viewing the status of a panel device.
class ViewPanelStatusUseCase {
  final DeviceRepository deviceRepository;

  /// Creates a [ViewPanelStatusUseCase] with the given [deviceRepository].
  ViewPanelStatusUseCase({required this.deviceRepository});

  /// Retrieves the current status of the panel with the given [handle].
  TaskEither<Failure, Device> call({required DeviceHandle handle}) {
    return deviceRepository
        .getByHandle(handle: handle)
        .mapLeft((failure) => failure)
        .map((result) => result.device);
  }
}
