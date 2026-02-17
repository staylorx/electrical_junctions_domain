import 'package:electrical_junctions_entities/index.dart';

/// Base class for specification-related failures
class SpecificationFailure extends Failure {
  final String typeName;
  final String specificationName;

  SpecificationFailure(this.typeName, this.specificationName, String message)
    : super(
        'Specification "$specificationName" failed for type "$typeName": $message',
      );
}
