import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Creates a new device and saves it to the repository.
///
/// Following the UseCase standard, this accepts:
/// - Simple business parameters for the entity being created (name)
/// - The DeviceSpecification value object (required for device definition)
/// - A handle for related persisted entities (locateHandle)
class CreateDeviceUseCase {
  final DeviceRepository _deviceRepository;
  final LocateRepository _locateRepository;

  CreateDeviceUseCase({
    required DeviceRepository deviceRepository,
    required LocateRepository locateRepository,
  }) : _deviceRepository = deviceRepository,
       _locateRepository = locateRepository;

  /// Creates and saves a device
  ///
  /// Returns the created device on success, or a Failure on error.
  TaskEither<Failure, Device> call({
    String? name,
    required DeviceSpecification deviceSpecification,
    LocateHandle? locateHandle,
  }) {
    // If no locate handle, create device without location
    if (locateHandle == null) {
      return _createAndSaveDevice(
        name: name,
        deviceSpecification: deviceSpecification,
        locate: null,
      );
    }

    // Fetch the locate and then create the device with it
    return _locateRepository.getByHandle(handle: locateHandle).flatMap((
      locateWithHandle,
    ) {
      return _createAndSaveDevice(
        name: name,
        deviceSpecification: deviceSpecification,
        locate: locateWithHandle.locate,
      );
    });
  }

  /// Creates and saves a device instance
  TaskEither<Failure, Device> _createAndSaveDevice({
    String? name,
    required DeviceSpecification deviceSpecification,
    Locate? locate,
  }) {
    final device = Device(
      name: name,
      deviceSpecification: deviceSpecification,
      locate: locate,
    );
    // Save to repository - repository will handle adding the handle
    return _deviceRepository
        .create(item: device)
        .map((savedDeviceWithHandle) => savedDeviceWithHandle.device);
  }
}
