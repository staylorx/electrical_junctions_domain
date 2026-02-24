import '../../index.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the `CreatePanelReportUseCase` class.
class CreatePanelReportUseCase {
  final CircuitRepository circuitRepository;

  CreatePanelReportUseCase({required this.circuitRepository});

  TaskEither<Failure, String> call({required Device panel}) {
    // Validate panel is a Panel
    if (panel.deviceSpecification.typeId != 'panel') {
      return TaskEither.left(UCValidationFailure('Device must be a Panel'));
    }

    return circuitRepository.getAll().map((circuits) {
      // Fetch slots - find all panel_slot circuits for this panel
      final slots = circuits
          .where(
            (c) =>
                c.circuit.stereotype == 'panel_slot' &&
                c.circuit.sourceDevice.handle!.value == panel.handle!.value,
          )
          .toList();

      // Generate report
      final report = StringBuffer();
      report.writeln('Panel Report');
      report.writeln('Panel: ${panel.locate?.name ?? 'Unknown'}');
      report.writeln();

      /// Executes `for`.
      for (final slot in slots) {
        report.writeln('Slot ${slot.circuit.name}:');

        final circuitBreaker = slot.circuit.connectedDevices.isNotEmpty
            ? slot.circuit.connectedDevices.first
            : null;

        /// Executes `if`.
        if (circuitBreaker != null) {
          // Validate circuitBreaker is a CircuitBreaker
          assert(
            circuitBreaker.deviceSpecification.typeId == 'circuit_breaker',
            'Connected device must be a CircuitBreaker',
          );

          report.writeln(
            '  Circuit Breaker: ${circuitBreaker.deviceSpecification.manufacturer.name} ${circuitBreaker.deviceSpecification.properties['ampRating'] ?? 'N/A'}A ${circuitBreaker.deviceSpecification.properties['poleCount'] ?? 'N/A'}P',
          );

          final slotCircuits = circuits
              .where(
                (c) =>
                    c.circuit.stereotype != 'panel_slot' &&
                    c.circuit.sourceDevice.handle!.value ==
                        circuitBreaker.handle!.value,
              )
              .toList();

          /// Executes `if`.
          if (slotCircuits.isNotEmpty) {
            report.writeln('  Circuits (${slotCircuits.length}):');

            /// Executes `for`.
            for (final circuit in slotCircuits) {
              final deviceNames = circuit.circuit.connectedDevices
                  .map((d) => d.locate?.name ?? 'Unknown')
                  .join(', ');
              report.writeln(
                '    - ${deviceNames.isNotEmpty ? deviceNames : 'No devices'}',
              );
            }
          } else {
            report.writeln('  Circuits: None');
          }
        } else {
          report.writeln('  Circuit Breaker: None');
          report.writeln('  Circuits: N/A');
        }
        report.writeln();
      }

      return report.toString().trim();
    });
  }
}
