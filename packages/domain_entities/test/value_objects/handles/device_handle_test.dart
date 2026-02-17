import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given DeviceHandle', () {
    group('When creating a handle', () {
      test('Then it should create with value', () {
        final handle = DeviceHandle('device-123');

        handle.value.should.be('device-123');
      });
    });

    group('When checking equality', () {
      test('Then handles with same value should be equal', () {
        final handle1 = DeviceHandle('device-123');
        final handle2 = DeviceHandle('device-123');

        handle1.should.be(handle2);
      });

      test('Then handles with different values should not be equal', () {
        final handle1 = DeviceHandle('device-123');
        final handle2 = DeviceHandle('device-456');

        handle1.should.not.be(handle2);
      });
    });

    group('When converting to string', () {
      test('Then it should return the value', () {
        final handle = DeviceHandle('device-123');

        handle.toString().should.be('device-123');
      });
    });
  });
}
