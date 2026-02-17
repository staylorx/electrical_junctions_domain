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

  TaskEither<Failure, Unit> call({required Circuit panelSlot}) {
    if (panelSlot.stereoType != 'panel_slot') {
      return TaskEither.left(
        UCValidationFailure('Circuit must be a panel_slot'),
      );
    }

    final circuitBreaker = panelSlot.connectedDevices.isNotEmpty
        ? panelSlot.connectedDevices.first
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

    if (panelSlot.sourceDevice.deviceSpecification.typeId != 'panel') {
      return TaskEither.left(
        UCValidationFailure('Panel slot source device must be a Panel'),
      );
    }

    final panel = panelSlot.sourceDevice;

    return circuitRepository.getAll().flatMap((circuits) {
      final slots = circuits
          .where(
            (c) =>
                c.stereoType == 'panel_slot' &&
                c.sourceDevice.handle.value == panel.handle.value,
          )
          .toList();

      final slotToUpdate = slots
          .where((slot) => slot.name == panelSlot.name)
          .firstOrNull;

      if (slotToUpdate == null) {
        return TaskEither.left(UCValidationFailure('Slot not found in panel'));
      }

      final updatedSlot = slotToUpdate.copyWith(connectedDevices: []);

      return updateCircuitUseCase.call(circuit: updatedSlot).flatMap((_) {
        return circuitRepository.getAll().flatMap((allCircuits) {
          final circuitToDelete = allCircuits
              .where(
                (c) =>
                    c.stereoType != 'panel_slot' &&
                    c.sourceDevice.handle.value == circuitBreaker.handle.value,
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
