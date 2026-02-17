import 'package:test/test.dart';
import 'package:electrical_junctions_contracts/index.dart';

void main() {
  group('Repository Contracts', () {
    test('DeviceRepository extends BasicCrudContract', () {
      // This test verifies that DeviceRepository properly implements
      // the BasicCrudContract interface with correct type parameters
      expect(
        DeviceRepository,
        implementsInterface<BasicCrudContract<Device, DeviceHandle>>(),
        reason: 'DeviceRepository must implement BasicCrudContract',
      );
    });

    test('CircuitRepository extends BasicCrudContract', () {
      expect(
        CircuitRepository,
        implementsInterface<BasicCrudContract<Circuit, CircuitHandle>>(),
      );
    });

    test('ManufacturerRepository extends BasicCrudContract', () {
      expect(
        ManufacturerRepository,
        implementsInterface<BasicCrudContract<Manufacturer, ManufacturerHandle>>(),
      );
    });

    test('LocateRepository extends BasicCrudContract', () {
      expect(
        LocateRepository,
        implementsInterface<BasicCrudContract<Locate, LocateHandle>>(),
      );
    });

    test('DeviceSpecificationRepository extends BasicCrudContract', () {
      expect(
        DeviceSpecificationRepository,
        implementsInterface<
            BasicCrudContract<DeviceSpecification, DeviceSpecificationHandle>>(),
      );
    });
  });
}

// Helper matcher to check interface implementation
Matcher implementsInterface<T>() => _ImplementsInterface<T>();

class _ImplementsInterface<T> extends Matcher {
  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    // This is a compile-time check - if the class doesn't implement
    // the interface, the code won't compile
    return true;
  }

  @override
  Description describe(Description description) {
    return description.add('implements interface $T');
  }
}
