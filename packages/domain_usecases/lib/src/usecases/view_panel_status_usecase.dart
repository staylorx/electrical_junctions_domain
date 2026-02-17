import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for viewing the status of a panel device.
class ViewPanelStatusUseCase {
  final DeviceRepository deviceRepository;

  /// Creates a [ViewPanelStatusUseCase] with the given [deviceRepository].
  ViewPanelStatusUseCase({required this.deviceRepository});

  /// Retrieves the current status of the given panel [device].
  TaskEither<Failure, Device> call({required Device device}) {
    assert(
      device.deviceSpecification.typeId == 'panel',
      'Device must be a Panel',
    );
    return deviceRepository.getByHandle(handle: device.handle);
  }
}
