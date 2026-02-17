import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given CircuitHandle', () {
    group('When creating a handle', () {
      test('Then it should create with value', () {
        final handle = CircuitHandle('circuit-123');

        handle.value.should.be('circuit-123');
      });
    });

    group('When checking equality', () {
      test('Then handles with same value should be equal', () {
        final handle1 = CircuitHandle('circuit-123');
        final handle2 = CircuitHandle('circuit-123');

        handle1.should.be(handle2);
      });

      test('Then handles with different values should not be equal', () {
        final handle1 = CircuitHandle('circuit-123');
        final handle2 = CircuitHandle('circuit-456');

        handle1.should.not.be(handle2);
      });
    });
  });
}
