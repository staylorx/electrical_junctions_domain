import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the `InstallCircuitBreakerUseCase` class.
class InstallCircuitBreakerUseCase {
  final UpdateCircuitUseCase updateCircuitUseCase;
  final CreateCircuitUseCase createCircuitUseCase;

  InstallCircuitBreakerUseCase({
    UpdateCircuitUseCase? updateCircuitUseCase,
    CreateCircuitUseCase? createCircuitUseCase,
    CircuitRepository? circuitRepository,
  }) : updateCircuitUseCase =
           updateCircuitUseCase ??
           UpdateCircuitUseCase(circuitRepository: circuitRepository!),
       createCircuitUseCase =
           createCircuitUseCase ??
           CreateCircuitUseCase(circuitRepository: circuitRepository!);

  TaskEither<Failure, Circuit> call({
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

    return updateCircuitUseCase
        .call(circuit: updatedPanelSlot, handle: panelSlot.handle)
        .flatMap((_) {
          return createCircuitUseCase
              .call(sourceDevice: circuitBreaker, connectedDevices: [])
              .map((circuitWithHandle) => circuitWithHandle.circuit);
        });
  }
}
