import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the `RemoveCircuitBreakerUseCase` class.
class RemoveCircuitBreakerUseCase {
  final CircuitRepository circuitRepository;
  final UpdateCircuitUseCase updateCircuitUseCase;
  final DeleteCircuitUseCase deleteCircuitUseCase;

  RemoveCircuitBreakerUseCase({
    CircuitRepository? circuitRepository,
    UpdateCircuitUseCase? updateCircuitUseCase,
    DeleteCircuitUseCase? deleteCircuitUseCase,
  }) : circuitRepository = circuitRepository!,
       updateCircuitUseCase =
           updateCircuitUseCase ??
           UpdateCircuitUseCase(circuitRepository: circuitRepository),
       deleteCircuitUseCase =
           deleteCircuitUseCase ??
           DeleteCircuitUseCase(circuitRepository: circuitRepository);

  TaskEither<Failure, Unit> call({required CircuitWithHandle panelSlot}) {
    if (panelSlot.circuit.stereotype != 'panel_slot') {
      return TaskEither.left(
        UCValidationFailure('Circuit must be a panel_slot'),
      );
    }

    final circuitBreaker = panelSlot.circuit.connectedDevices.isNotEmpty
        ? panelSlot.circuit.connectedDevices.first
        : null;

    if (circuitBreaker == null) {
      return TaskEither.left(
        UCValidationFailure('Panel slot has no circuit breaker'),
      );
    }

    if (circuitBreaker.deviceSpecification.typeId != 'circuit_breaker') {
      return TaskEither.left(
        UCValidationFailure('Connected device must be a CircuitBreaker'),
      );
    }

    if (panelSlot.circuit.sourceDevice.deviceSpecification.typeId != 'panel') {
      return TaskEither.left(
        UCValidationFailure('Panel slot source device must be a Panel'),
      );
    }

    final panel = panelSlot.circuit.sourceDevice;

    return circuitRepository.getAll().flatMap((circuits) {
      final slots = circuits
          .where(
            (c) =>
                c.circuit.stereotype == 'panel_slot' &&
                c.circuit.sourceDevice == panel,
          )
          .toList();

      final slotToUpdate = slots
          .where((slot) => slot.circuit.name == panelSlot.circuit.name)
          .firstOrNull;

      if (slotToUpdate == null) {
        return TaskEither.left(UCValidationFailure('Slot not found in panel'));
      }

      final updatedSlot = slotToUpdate.copyWith(
        circuit: slotToUpdate.circuit.copyWith(connectedDevices: []),
      );

      return updateCircuitUseCase
          .call(circuit: updatedSlot.circuit, handle: updatedSlot.handle)
          .flatMap((_) {
            return circuitRepository.getAll().flatMap((allCircuits) {
              final circuitToDelete = allCircuits
                  .where(
                    (c) =>
                        c.circuit.stereotype != 'panel_slot' &&
                        c.circuit.sourceDevice == circuitBreaker,
                  )
                  .firstOrNull;

              if (circuitToDelete != null) {
                return deleteCircuitUseCase
                    .call(handle: circuitToDelete.handle)
                    .map((_) => unit);
              }

              return TaskEither.right(unit);
            });
          });
    });
  }
}
