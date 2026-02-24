import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given a Circuit entity', () {
    late DeviceHandle sourceHandle;
    late Device sourceDevice;
    late DeviceSpecification testSpec;

    setUp(() {
      sourceHandle = DeviceHandle('device-456');
      final manufacturer = Manufacturer(
        handle: ManufacturerHandle('mfg-1'),
        name: 'Square D',
      );
      testSpec = DeviceSpecification(
        typeId: 'panel',
        modelNumber: 'QO-200A',
        manufacturer: manufacturer,
      );
      sourceDevice = Device(
        handle: sourceHandle,
        deviceSpecification: testSpec,
      );
    });

    group('When creating a circuit', () {
      test('Then it should create with required fields', () {
        final circuit = Circuit(
          sourceDevice: sourceDevice,
          connectedDevices: [],
        );

        circuit.sourceDevice.should.be(sourceDevice);
        circuit.connectedDevices.should.beEmpty();
        circuit.name.should.beNull();
        circuit.stereotype.should.beNull();
      });

      test('Then it should create with connected devices', () {
        final connectedDevice = Device(
          handle: DeviceHandle('connected-1'),
          deviceSpecification: testSpec,
        );

        final circuit = Circuit(
          sourceDevice: sourceDevice,
          connectedDevices: [connectedDevice],
        );

        circuit.connectedDevices.length.should.be(1);
        circuit.connectedDevices.first.should.be(connectedDevice);
      });

      test('Then it should create with stereotype', () {
        final circuit = Circuit(
          sourceDevice: sourceDevice,
          stereotype: 'panel_slot',
          connectedDevices: [],
        );

        circuit.stereotype.should.be('panel_slot');
      });
    });

    group('When checking equality', () {
      test('Then circuits with same properties should be equal', () {
        final circuit1 = Circuit(
          sourceDevice: sourceDevice,
          name: 'Circuit A1',
          connectedDevices: [],
        );

        final circuit2 = Circuit(
          sourceDevice: sourceDevice,
          name: 'Circuit A1',
          connectedDevices: [],
        );

        circuit1.should.be(circuit2);
      });

      test('Then circuits with different names should not be equal', () {
        final circuit1 = Circuit(
          sourceDevice: sourceDevice,
          name: 'Circuit A1',
          connectedDevices: [],
        );

        final circuit2 = Circuit(
          sourceDevice: sourceDevice,
          name: 'Circuit B1',
          connectedDevices: [],
        );

        circuit1.should.not.be(circuit2);
      });
    });
  });
}
