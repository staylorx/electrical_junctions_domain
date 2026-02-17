import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given a Manufacturer entity', () {
    late ManufacturerHandle testHandle;

    setUp(() {
      testHandle = ManufacturerHandle('mfg-123');
    });

    group('When creating a manufacturer', () {
      test('Then it should create with required fields', () {
        final manufacturer = Manufacturer(
          handle: testHandle,
          name: 'Square D',
        );

        manufacturer.handle.should.be(testHandle);
        manufacturer.name.should.be('Square D');
      });
    });

    group('When checking equality', () {
      test('Then manufacturers with same properties should be equal', () {
        final mfg1 = Manufacturer(
          handle: testHandle,
          name: 'Square D',
        );

        final mfg2 = Manufacturer(
          handle: testHandle,
          name: 'Square D',
        );

        mfg1.should.be(mfg2);
      });

      test('Then manufacturers with different names should not be equal', () {
        final mfg1 = Manufacturer(
          handle: testHandle,
          name: 'Square D',
        );

        final mfg2 = Manufacturer(
          handle: testHandle,
          name: 'Eaton',
        );

        mfg1.should.not.be(mfg2);
      });
    });
  });
}
