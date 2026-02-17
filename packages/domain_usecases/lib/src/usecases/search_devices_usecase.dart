import 'package:fpdart/fpdart.dart';
import 'package:electrical_junctions_contracts/index.dart';

/// Use case for searching devices based on various criteria.
class SearchDevicesUseCase {
  final DeviceRepository deviceRepository;

  /// Creates a [SearchDevicesUseCase] with the given [deviceRepository].
  SearchDevicesUseCase({required this.deviceRepository});

  /// Searches for devices matching the provided filters.
  TaskEither<Failure, List<Device>> call({
    String? typeId,
    String? location,
    Manufacturer? manufacturer,
    Locate? locate,
    int? amperage,
    int? poles,
  }) {
    final devicesTask = typeId != null
        ? deviceRepository.getDevicesByType(typeId)
        : deviceRepository.getAll();

    return devicesTask.map((devices) {
      var filtered = devices;

      // Filter by location (only for panels)
      if (location != null) {
        filtered = filtered
            .where(
              (d) =>
                  d.deviceSpecification.typeId == 'panel' &&
                  d.locate?.name == location,
            )
            .toList();
      }

      // Filter by manufacturer
      if (manufacturer != null) {
        filtered = filtered
            .where((d) => d.deviceSpecification.manufacturer == manufacturer)
            .toList();
      }

      // Filter by locate
      if (locate != null) {
        filtered = filtered.where((d) => d.locate == locate).toList();
      }

      // Filter by amperage
      if (amperage != null) {
        filtered = filtered
            .where(
              (d) =>
                  d.deviceSpecification.safeGetProperty<int>('ampRating') ==
                  amperage,
            )
            .toList();
      }

      // Filter by poles
      if (poles != null) {
        filtered = filtered
            .where(
              (d) =>
                  d.deviceSpecification.safeGetProperty<int>('poleCount') ==
                  poles,
            )
            .toList();
      }

      return filtered;
    });
  }
}
