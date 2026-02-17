import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Creates a new device and saves it to the repository.
///
/// This use case handles device creation by directly instantiating the Device
/// entity with the provided specification. Device type validation is handled
/// by ensuring a valid DeviceSpecification is provided.
class CreateDeviceUseCase {
  final DeviceRepository _deviceRepository;
  final HandleGenerator _handleGenerator;

  CreateDeviceUseCase({
    required DeviceRepository deviceRepository,
    required HandleGenerator handleGenerator,
  }) : _deviceRepository = deviceRepository,
       _handleGenerator = handleGenerator;

  /// Creates and saves a device
  ///
  /// Returns the created device on success, or a Failure on error.
  TaskEither<Failure, Device> call({
    String? name,
    required DeviceSpecification deviceSpecification,
    Locate? locate,
  }) {
    return _createDevice(
      name: name,
      deviceSpecification: deviceSpecification,
      locate: locate,
    ).flatMap((device) => _saveDevice(device: device));
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
    return _deviceRepository.create(item: device).map((_) => device);
  }
}
