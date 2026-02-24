import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the `SlotCircuitBreakerIntoPanelSlotUseCase` class.
class SlotCircuitBreakerIntoPanelSlotUseCase {
  final DeviceRepository deviceRepository;
  final CircuitRepository circuitRepository;
  final UpdateCircuitUseCase updateCircuitUseCase;

  SlotCircuitBreakerIntoPanelSlotUseCase({
    required this.deviceRepository,
    required this.circuitRepository,
    UpdateCircuitUseCase? updateCircuitUseCase,
  }) : updateCircuitUseCase =
           updateCircuitUseCase ??
           UpdateCircuitUseCase(circuitRepository: circuitRepository);

  TaskEither<Failure, Circuit> call({
    required Device circuitBreaker,
    required Device panel,
    required CircuitWithHandle panelSlot,
  }) {
    // Validate circuitBreaker is a CircuitBreaker
    if (circuitBreaker.deviceSpecification.typeId != 'circuit_breaker') {
      return TaskEither.left(
        UCValidationFailure('Device must be a CircuitBreaker'),
      );
    }

    // Validate panel is a Panel
    if (panel.deviceSpecification.typeId != 'panel') {
      return TaskEither.left(UCValidationFailure('Device must be a Panel'));
    }

    // Validate panelSlot is a panel_slot circuit
    if (panelSlot.circuit.stereotype != 'panel_slot') {
      return TaskEither.left(
        UCValidationFailure('Circuit must be a panel_slot'),
      );
    }

    return circuitRepository.getAll().flatMap((circuits) {
      // Locate all panel slots for this panel
      final slots = circuits
          .where(
            (c) =>
                c.circuit.stereotype == 'panel_slot' &&
                c.circuit.sourceDevice == panel,
          )
          .toList();

      // Find the target slot by matching code (name)
      final targetSlot = slots
          .where((slot) => slot.circuit.name == panelSlot.circuit.name)
          .firstOrNull;

      if (targetSlot == null) {
        return TaskEither.left(UCValidationFailure('Slot not found in panel'));
      }

      // Check if the slot is available (not occupied)
      if (targetSlot.circuit.connectedDevices.isNotEmpty) {
        return TaskEither.left(UCValidationFailure('Slot is occupied'));
      }

      // Check if the breaker poles fit within the panel's poles
      if ((circuitBreaker.deviceSpecification.safeGetProperty<int>(
                'poleCount',
              ) ??
              0) >
          (panel.deviceSpecification.safeGetProperty<int>('poleCount') ?? 0)) {
        return TaskEither.left(
          UCValidationFailure('Breaker poles exceed panel poles'),
        );
      }

      // Create a new updated slot with the circuitBreaker assigned
      final updatedSlot = targetSlot.copyWith(
        circuit: targetSlot.circuit.copyWith(
          connectedDevices: [circuitBreaker],
        ),
      );

      // Save the updated slot via UpdateCircuitUseCase
      return updateCircuitUseCase
          .call(circuit: updatedSlot.circuit, handle: updatedSlot.handle)
          .map((_) => updatedSlot.circuit);
    });
  }
}
