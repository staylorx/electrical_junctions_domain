import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given a Circuit entity', () {
    late CircuitHandle testHandle;
    late DeviceHandle sourceHandle;
    late Device sourceDevice;
    late DeviceSpecification testSpec;

    setUp(() {
      testHandle = CircuitHandle('circuit-123');
      sourceHandle = DeviceHandle('device-456');
      final manufacturer = Manufacturer(id: 'mfg-1', name: 'Square D');
      testSpec = DeviceSpecification(
        handle: DeviceSpecificationHandle('spec-1'),
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
          handle: testHandle,
          sourceDevice: sourceDevice,
          connectedDevices: [],
        );

        circuit.handle.should.be(testHandle);
        circuit.sourceDevice.should.be(sourceDevice);
        circuit.connectedDevices.should.beEmpty();
        circuit.name.should.beNull();
        circuit.stereoType.should.beNull();
      });

      test('Then it should create with connected devices', () {
        final connectedDevice = Device(
          handle: DeviceHandle('connected-1'),
          deviceSpecification: testSpec,
        );

        final circuit = Circuit(
          handle: testHandle,
          sourceDevice: sourceDevice,
          connectedDevices: [connectedDevice],
        );

        circuit.connectedDevices.length.should.be(1);
        circuit.connectedDevices.first.should.be(connectedDevice);
      });

      test('Then it should create with stereotype', () {
        final circuit = Circuit(
          handle: testHandle,
          sourceDevice: sourceDevice,
          stereoType: 'panel_slot',
          connectedDevices: [],
        );

        circuit.stereoType.should.be('panel_slot');
      });
    });

    group('When checking equality', () {
      test('Then circuits with same properties should be equal', () {
        final circuit1 = Circuit(
          handle: testHandle,
          sourceDevice: sourceDevice,
          name: 'Circuit A1',
          connectedDevices: [],
        );

        final circuit2 = Circuit(
          handle: testHandle,
          sourceDevice: sourceDevice,
          name: 'Circuit A1',
          connectedDevices: [],
        );

        circuit1.should.be(circuit2);
      });

      test('Then circuits with different handles should not be equal', () {
        final circuit1 = Circuit(
          handle: testHandle,
          sourceDevice: sourceDevice,
          connectedDevices: [],
        );

        final circuit2 = Circuit(
          handle: CircuitHandle('different-handle'),
          sourceDevice: sourceDevice,
          connectedDevices: [],
        );

        circuit1.should.not.be(circuit2);
      });
    });
  });
}
