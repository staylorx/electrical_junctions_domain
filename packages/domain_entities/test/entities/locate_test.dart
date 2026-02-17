import 'package:electrical_junctions_entities/index.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('Given a Locate entity', () {
    group('When converting to string representation', () {
      test('Then should return name when no parent exists', () {
        final mainBuilding = Locate(id: 'building1', name: 'Main Building');
        mainBuilding.toString().should.be('Main Building');
      });

      test('Then should return parent > name when parent exists', () {
        final mainBuilding = Locate(id: 'building1', name: 'Main Building');
        final floor1 = Locate(
          id: 'floor1',
          name: 'Floor 1',
          parentLocate: mainBuilding,
        );
        floor1.toString().should.be('Main Building > Floor 1');
      });

      test('Then should return full hierarchy recursively', () {
        final mainBuilding = Locate(id: 'building1', name: 'Main Building');
        final floor1 = Locate(
          id: 'floor1',
          name: 'Floor 1',
          parentLocate: mainBuilding,
        );
        final room101 = Locate(
          id: 'room101',
          name: 'Room 101',
          parentLocate: floor1,
        );
        room101.toString().should.be('Main Building > Floor 1 > Room 101');
      });
    });
  });
}
