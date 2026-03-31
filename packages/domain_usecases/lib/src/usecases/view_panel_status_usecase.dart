import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for viewing the status of a panel device.
///
/// Following the UseCase standard, returns DeviceWithHandle to provide
/// the handle for UI layer operations.
class ViewPanelStatusUseCase {
  final DeviceRepository deviceRepository;

  /// Creates a [ViewPanelStatusUseCase] with the given [deviceRepository].
  ViewPanelStatusUseCase({required this.deviceRepository});

  /// Retrieves the current status of the panel with the given [handle].
  TaskEither<Failure, DeviceWithHandle> call({required DeviceHandle handle}) {
    return deviceRepository.getByHandle(handle: handle);
  }
}
