import 'package:electrical_junctions_entities/index.dart';

class DatastoreFailure extends Failure {
  DatastoreFailure(super.message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure(super.message);
}

class DuplicateFailure extends Failure {
  DuplicateFailure(super.message);
}

class ServiceFailure extends Failure {
  ServiceFailure(super.message);
}
