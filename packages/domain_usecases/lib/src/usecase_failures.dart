import 'package:electrical_junctions_entities/index.dart';

/// Use case operation failure.
class UsecaseFailure extends Failure {
  UsecaseFailure(super.message);
}

class UCNotFoundFailure extends UsecaseFailure {
  UCNotFoundFailure(super.message);
}

class UCValidationFailure extends UsecaseFailure {
  UCValidationFailure(super.message);
}

class UCParsingFailure extends UsecaseFailure {
  UCParsingFailure(super.message);
}

class UCDatabaseReadFailure extends UsecaseFailure {
  UCDatabaseReadFailure(super.message);
}

class UCDatabaseWriteFailure extends UsecaseFailure {
  UCDatabaseWriteFailure(super.message);
}

class InvalidPropertyDefinitionFailure extends UsecaseFailure {
  final String key;

  InvalidPropertyDefinitionFailure(this.key, super.message);
}
