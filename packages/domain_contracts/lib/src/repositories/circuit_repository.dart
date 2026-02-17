import 'package:electrical_junctions_entities/index.dart';
import '../basic_crud_contract.dart';

/// Repository contract for `Circuit` entities.
/// Provides CRUD operations for electrical circuits, including panel slots
/// (represented as circuits with stereoType = "panel_slot").
abstract class CircuitRepository
    implements BasicCrudContract<Circuit, CircuitHandle> {
  // All CRUD operations inherited from BasicCrudContract
}
