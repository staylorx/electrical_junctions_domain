import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given ManufacturerValidator', () {
    group('When validating valid manufacturer data', () {
      test('Then it should return no errors for valid name', () {
        final errors = ManufacturerValidator.validate(name: 'Square D');

        errors.should.beEmpty();
      });
    });

    group('When validating invalid manufacturer data', () {
      test('Then it should return error for empty name', () {
        final errors = ManufacturerValidator.validate(name: '');

        errors.should.not.beEmpty();
        errors.first.should.contain('name cannot be empty');
      });
    });
  });
}
