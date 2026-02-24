import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given a DeviceSpecification entity', () {
    late Manufacturer testManufacturer;

    setUp(() {
      testManufacturer = Manufacturer(name: 'Square D');
    });

    group('When creating a device specification', () {
      test('Then it should create with required fields', () {
        final spec = DeviceSpecification(
          typeId: 'panel',
          modelNumber: 'QO-200A',
          manufacturer: testManufacturer,
        );

        spec.typeId.should.be('panel');
        spec.modelNumber.should.be('QO-200A');
        spec.manufacturer.should.be(testManufacturer);
        spec.properties.should.beEmpty();
      });

      test('Then it should create with manufacturer', () {
        final spec = DeviceSpecification(
          typeId: 'circuit_breaker',
          modelNumber: 'QO220',
          manufacturer: testManufacturer,
        );

        spec.manufacturer.should.be(testManufacturer);
      });

      test('Then it should create with properties', () {
        final spec = DeviceSpecification(
          typeId: 'panel',
          modelNumber: 'QO-200A',
          manufacturer: testManufacturer,
          properties: {'ampRating': 200, 'poles': 40},
        );

        expect(spec.properties['ampRating'], equals(200));
        expect(spec.properties['poles'], equals(40));
      });
    });

    group('When checking equality', () {
      test('Then specs with same properties should be equal', () {
        final spec1 = DeviceSpecification(
          typeId: 'panel',
          modelNumber: 'QO-200A',
          manufacturer: testManufacturer,
        );

        final spec2 = DeviceSpecification(
          typeId: 'panel',
          modelNumber: 'QO-200A',
          manufacturer: testManufacturer,
        );

        spec1.should.be(spec2);
      });

      test('Then specs with different model numbers should not be equal', () {
        final spec1 = DeviceSpecification(
          typeId: 'panel',
          modelNumber: 'QO-200A',
          manufacturer: testManufacturer,
        );

        final spec2 = DeviceSpecification(
          typeId: 'panel',
          modelNumber: 'QO-100A',
          manufacturer: testManufacturer,
        );

        spec1.should.not.be(spec2);
      });
    });
  });
}
