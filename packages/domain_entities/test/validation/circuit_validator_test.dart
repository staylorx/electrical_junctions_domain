import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given CircuitValidator', () {
    group('When validating valid circuit data', () {
      test('Then it should return no errors for valid named circuit', () {
        final errors = CircuitValidator.validate(
          name: 'Circuit A1',
          sourceDevice: DeviceHandle('device-1'),
          connectedDevices: [],
        );

        errors.should.beEmpty();
      });

      test('Then it should return no errors for circuit with connected devices', () {
        final errors = CircuitValidator.validate(
          name: 'Main Circuit',
          sourceDevice: DeviceHandle('device-1'),
          connectedDevices: [DeviceHandle('device-2')],
        );

        errors.should.beEmpty();
      });
    });

    group('When validating invalid circuit data', () {
      test('Then it should return error for empty name', () {
        final errors = CircuitValidator.validate(
          name: '',
          sourceDevice: DeviceHandle('device-1'),
          connectedDevices: [],
        );

        errors.should.not.beEmpty();
        errors.first.should.contain('name cannot be empty');
      });

      test('Then it should return error for name exceeding 50 characters', () {
        final errors = CircuitValidator.validate(
          name: 'A' * 51,
          sourceDevice: DeviceHandle('device-1'),
          connectedDevices: [],
        );

        errors.should.not.beEmpty();
        errors.first.should.contain('cannot exceed 50 characters');
      });

      test('Then it should return error when name is null and no connected devices', () {
        final errors = CircuitValidator.validate(
          sourceDevice: DeviceHandle('device-1'),
          connectedDevices: [],
        );

        errors.should.not.beEmpty();
        errors.first.should.contain('Connected devices list cannot be empty');
      });
    });
  });
}
