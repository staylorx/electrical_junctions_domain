import 'package:fpdart/fpdart.dart';
import 'package:electrical_junctions_contracts/index.dart';

/// Use case for searching devices based on various criteria.
///
/// Following the UseCase standard, accepts handles for related entities
/// rather than full objects.
class SearchDevicesUseCase {
  final DeviceRepository deviceRepository;
  final ManufacturerRepository manufacturerRepository;
  final LocateRepository locateRepository;

  /// Creates a [SearchDevicesUseCase] with the given repositories.
  SearchDevicesUseCase({
    required this.deviceRepository,
    required this.manufacturerRepository,
    required this.locateRepository,
  });

  /// Searches for devices matching the provided filters.
  TaskEither<Failure, List<Device>> call({
    String? typeId,
    String? location,
    ManufacturerHandle? manufacturerHandle,
    LocateHandle? locateHandle,
    int? amperage,
    int? poles,
  }) {
    final devicesTask = typeId != null
        ? deviceRepository.getDevicesByType(typeId)
        : deviceRepository.getAll();

    // Fetch manufacturer if handle provided
    final manufacturerTask = manufacturerHandle != null
        ? manufacturerRepository
              .getByHandle(handle: manufacturerHandle)
              .map((mfgWith) => mfgWith.manufacturer)
        : TaskEither<Failure, Manufacturer?>.right(null);

    // Fetch locate if handle provided
    final locateTask = locateHandle != null
        ? locateRepository
              .getByHandle(handle: locateHandle)
              .map((locWith) => locWith.locate)
        : TaskEither<Failure, Locate?>.right(null);

    return devicesTask
        .flatMap((devices) {
          return manufacturerTask.flatMap((manufacturer) {
            return locateTask.map((locate) {
              var filtered = devices;

              // Filter by location (only for panels)
              if (location != null) {
                filtered = filtered
                    .where(
                      (d) =>
                          d.device.deviceSpecification.typeId == 'panel' &&
                          d.device.locate?.name == location,
                    )
                    .toList();
              }

              // Filter by manufacturer
              if (manufacturer != null) {
                filtered = filtered
                    .where(
                      (d) =>
                          d.device.deviceSpecification.manufacturer ==
                          manufacturer,
                    )
                    .toList();
              }

              // Filter by locate
              if (locate != null) {
                filtered = filtered
                    .where((d) => d.device.locate == locate)
                    .toList();
              }

              // Filter by amperage
              if (amperage != null) {
                filtered = filtered
                    .where(
                      (d) =>
                          d.device.deviceSpecification.safeGetProperty<int>(
                            'ampRating',
                          ) ==
                          amperage,
                    )
                    .toList();
              }

              // Filter by poles
              if (poles != null) {
                filtered = filtered
                    .where(
                      (d) =>
                          d.device.deviceSpecification.safeGetProperty<int>(
                            'poleCount',
                          ) ==
                          poles,
                    )
                    .toList();
              }

              return filtered.map((d) => d.device).toList();
            });
          });
        })
        .mapLeft((failure) => failure);
  }
}
