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
  final HandleGenerator _handleGenerator;

  CreateDeviceUseCase({
    required DeviceRepository deviceRepository,
    required LocateRepository locateRepository,
    required HandleGenerator handleGenerator,
  }) : _deviceRepository = deviceRepository,
       _locateRepository = locateRepository,
       _handleGenerator = handleGenerator;

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
      return _createDevice(
        name: name,
        deviceSpecification: deviceSpecification,
        locate: null,
      ).flatMap((device) => _saveDevice(device: device));
    }

    // Fetch the locate and then create the device with it
    return _locateRepository.getByHandle(handle: locateHandle).flatMap((
      locateWithHandle,
    ) {
      return _createDevice(
        name: name,
        deviceSpecification: deviceSpecification,
        locate: locateWithHandle.locate,
      ).flatMap((device) => _saveDevice(device: device));
    });
  }

  /// Creates a device instance directly
  TaskEither<Failure, Device> _createDevice({
    String? name,
    required DeviceSpecification deviceSpecification,
    Locate? locate,
  }) {
    return TaskEither.tryCatch(
      () async {
        return Device(
          handle: _handleGenerator.generateDeviceHandle(),
          name: name,
          deviceSpecification: deviceSpecification,
          locate: locate,
        );
      },
      (error, stackTrace) =>
          UCValidationFailure('Failed to create device: $error'),
    );
  }

  /// Saves the device to the repository
  TaskEither<Failure, Device> _saveDevice({required Device device}) {
    return _deviceRepository
        .create(item: device)
        .map((deviceWithHandle) => device);
  }
}
