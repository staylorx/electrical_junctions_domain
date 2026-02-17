import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given DeviceValidator', () {
    group('When validating valid device data', () {
      test('Then it should return no errors for null name', () {
        final errors = DeviceValidator.validate();

        errors.should.beEmpty();
      });

      test('Then it should return no errors for valid name', () {
        final errors = DeviceValidator.validate(name: 'Main Panel');

        errors.should.beEmpty();
      });
    });

    group('When validating invalid device data', () {
      test('Then it should return error for empty name', () {
        final errors = DeviceValidator.validate(name: '');

        errors.should.not.beEmpty();
        errors.first.should.contain('name cannot be empty');
      });
    });
  });
}
