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
    HandleGenerator? handleGenerator,
  }) : updateCircuitUseCase =
           updateCircuitUseCase ??
           UpdateCircuitUseCase(circuitRepository: circuitRepository!),
       createCircuitUseCase =
           createCircuitUseCase ??
           CreateCircuitUseCase(
             circuitRepository: circuitRepository!,
             handleGenerator: handleGenerator!,
           );

  TaskEither<Failure, Circuit> call({
    required Device circuitBreaker,
    required Circuit panelSlot,
  }) {
    if (circuitBreaker.deviceSpecification.typeId != 'circuit_breaker') {
      return TaskEither.left(
        UCValidationFailure('Device must be a CircuitBreaker'),
      );
    }

    if (panelSlot.stereoType != 'panel_slot') {
      return TaskEither.left(
        UCValidationFailure('Circuit must be a panel_slot'),
      );
    }

    if (panelSlot.connectedDevices.isNotEmpty) {
      return TaskEither.left(
        UCValidationFailure('Panel slot already has a circuit breaker'),
      );
    }

    if (panelSlot.sourceDevice.deviceSpecification.typeId != 'panel') {
      return TaskEither.left(
        UCValidationFailure('Panel slot source device must be a Panel'),
      );
    }

    final updatedPanelSlot = panelSlot.copyWith(
      connectedDevices: [circuitBreaker],
    );

    return updateCircuitUseCase.call(circuit: updatedPanelSlot).flatMap((_) {
      return createCircuitUseCase.call(
        sourceDevice: circuitBreaker,
        connectedDevices: [],
      );
    });
  }
}
