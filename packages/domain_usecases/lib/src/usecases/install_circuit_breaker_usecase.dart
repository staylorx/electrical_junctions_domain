import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the `InstallCircuitBreakerUseCase` class.
///
/// This usecase installs a circuit breaker into a panel slot circuit by:
/// 1. Validating the circuit breaker device
/// 2. Updating the panel slot circuit with the breaker
/// 3. Creating a new circuit for the breaker
class InstallCircuitBreakerUseCase {
  final UpdateCircuitUseCase updateCircuitUseCase;
  final CreateCircuitUseCase createCircuitUseCase;
  final DeviceRepository deviceRepository;

  InstallCircuitBreakerUseCase({
    UpdateCircuitUseCase? updateCircuitUseCase,
    CreateCircuitUseCase? createCircuitUseCase,
    CircuitRepository? circuitRepository,
    DeviceRepository? deviceRepository,
  }) : updateCircuitUseCase =
           updateCircuitUseCase ??
           UpdateCircuitUseCase(circuitRepository: circuitRepository!),
       createCircuitUseCase =
           createCircuitUseCase ??
           CreateCircuitUseCase(
             circuitRepository: circuitRepository!,
             deviceRepository: deviceRepository!,
           ),
       deviceRepository = deviceRepository!;

  TaskEither<Failure, CircuitWithHandle> call({
    required Device circuitBreaker,
    required CircuitWithHandle panelSlot,
  }) {
    if (circuitBreaker.deviceSpecification.typeId != 'circuit_breaker') {
      return TaskEither.left(
        UCValidationFailure('Device must be a CircuitBreaker'),
      );
    }

    if (panelSlot.circuit.stereotype != 'panel_slot') {
      return TaskEither.left(
        UCValidationFailure('Circuit must be a panel_slot'),
      );
    }

    if (panelSlot.circuit.connectedDevices.isNotEmpty) {
      return TaskEither.left(
        UCValidationFailure('Panel slot already has a circuit breaker'),
      );
    }

    if (panelSlot.circuit.sourceDevice.deviceSpecification.typeId != 'panel') {
      return TaskEither.left(
        UCValidationFailure('Panel slot source device must be a Panel'),
      );
    }

    final updatedPanelSlot = panelSlot.circuit.copyWith(
      connectedDevices: [circuitBreaker],
    );

    // To create a circuit for the breaker, we need its handle
    // Fetch from the device repository to find the breaker's handle
    return deviceRepository.getAll().flatMap((devicesWithHandles) {
      // Find the breaker's handle by matching device specs
      DeviceWithHandle? breakerWithHandle;
      try {
        breakerWithHandle = devicesWithHandles.firstWhere(
          (dwh) =>
              dwh.device.deviceSpecification ==
                  circuitBreaker.deviceSpecification &&
              dwh.device.name == circuitBreaker.name,
        );
      } catch (_) {
        breakerWithHandle = null;
      }

      if (breakerWithHandle == null) {
        return TaskEither<Failure, CircuitWithHandle>.left(
          UCValidationFailure('Circuit breaker not found in repository'),
        );
      }

      return updateCircuitUseCase
          .call(circuit: updatedPanelSlot, handle: panelSlot.handle)
          .flatMap((_) {
            return createCircuitUseCase.call(
              sourceDeviceHandle: breakerWithHandle!.handle,
              connectedDeviceHandles: [],
            );
          });
    });
  }
}
