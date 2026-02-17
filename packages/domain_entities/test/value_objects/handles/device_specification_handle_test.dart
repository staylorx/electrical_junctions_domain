import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given DeviceSpecificationHandle', () {
    group('When creating a handle', () {
      test('Then it should create with value', () {
        final handle = DeviceSpecificationHandle('spec-123');

        handle.value.should.be('spec-123');
      });
    });

    group('When checking equality', () {
      test('Then handles with same value should be equal', () {
        final handle1 = DeviceSpecificationHandle('spec-123');
        final handle2 = DeviceSpecificationHandle('spec-123');

        handle1.should.be(handle2);
      });

      test('Then handles with different values should not be equal', () {
        final handle1 = DeviceSpecificationHandle('spec-123');
        final handle2 = DeviceSpecificationHandle('spec-456');

        handle1.should.not.be(handle2);
      });
    });
  });
}
