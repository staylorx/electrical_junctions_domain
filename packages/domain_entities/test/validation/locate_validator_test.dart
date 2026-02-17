import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given LocateValidator', () {
    group('When validating valid locate data', () {
      test('Then it should return no errors for valid name', () {
        final errors = LocateValidator.validate(name: 'Room 101');

        errors.should.beEmpty();
      });
    });

    group('When validating invalid locate data', () {
      test('Then it should return error for empty name', () {
        final errors = LocateValidator.validate(name: '');

        errors.should.not.beEmpty();
        errors.first.should.contain('name cannot be empty');
      });
    });
  });
}
