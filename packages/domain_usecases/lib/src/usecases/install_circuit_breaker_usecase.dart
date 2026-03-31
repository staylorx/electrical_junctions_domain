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

    // Get the circuit breaker handle from the device or repository
    final breakerHandle = circuitBreaker.handle;
    if (breakerHandle == null) {
      return TaskEither.left(
        UCValidationFailure('Circuit breaker device must have a handle'),
      );
    }

    return updateCircuitUseCase
        .call(circuit: updatedPanelSlot, handle: panelSlot.handle)
        .flatMap((_) {
          return createCircuitUseCase.call(
            sourceDeviceHandle: breakerHandle,
            connectedDeviceHandles: [],
          );
        });
  }
}
