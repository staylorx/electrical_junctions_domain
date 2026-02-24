import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given a Device entity', () {
    late DeviceHandle testHandle;
    late DeviceSpecification testSpec;
    late Locate testLocation;

    setUp(() {
      testHandle = DeviceHandle('device-123');
      final manufacturer = Manufacturer(
        handle: ManufacturerHandle('mfg-1'),
        name: 'Square D',
      );
      testSpec = DeviceSpecification(
        typeId: 'panel',
        modelNumber: 'QO-200A',
        manufacturer: manufacturer,
      );
      testLocation = Locate(name: 'Room 101');
    });

    group('When creating a device', () {
      test('Then it should create with required fields', () {
        final device = Device(
          handle: testHandle,
          deviceSpecification: testSpec,
        );

        device.handle.should.be(testHandle);
        device.deviceSpecification.should.be(testSpec);
        device.name.should.beNull();
        device.locate.should.beNull();
      });

      test('Then it should create with all fields', () {
        final device = Device(
          handle: testHandle,
          deviceSpecification: testSpec,
          name: 'Main Panel',
          locate: testLocation,
        );

        device.handle.should.be(testHandle);
        device.deviceSpecification.should.be(testSpec);
        device.name.should.be('Main Panel');
        device.locate.should.be(testLocation);
      });
    });

    group('When checking equality', () {
      test('Then devices with same properties should be equal', () {
        final device1 = Device(
          handle: testHandle,
          deviceSpecification: testSpec,
          name: 'Main Panel',
          locate: testLocation,
        );

        final device2 = Device(
          handle: testHandle,
          deviceSpecification: testSpec,
          name: 'Main Panel',
          locate: testLocation,
        );

        device1.should.be(device2);
      });

      test('Then devices with different handles should not be equal', () {
        final device1 = Device(
          handle: testHandle,
          deviceSpecification: testSpec,
        );

        final device2 = Device(
          handle: DeviceHandle('different-handle'),
          deviceSpecification: testSpec,
        );

        device1.should.not.be(device2);
      });
    });

    group('When accessing device specification', () {
      test('Then it should return the specification', () {
        final device = Device(
          handle: testHandle,
          deviceSpecification: testSpec,
        );

        device.deviceSpecification.should.be(testSpec);
        device.deviceSpecification.modelNumber.should.be('QO-200A');
      });
    });
  });
}
