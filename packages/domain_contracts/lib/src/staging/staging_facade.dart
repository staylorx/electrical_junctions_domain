import 'repository_access.dart';

/// Factory for creating a fresh StagingFacade instance.
typedef StagingFacadeFactory = StagingFacade Function();

/// Abstract facade for staging imported data.
/// Provides access to repositories containing the staged entities.
abstract class StagingFacade {
  /// Provides access to the repositories for advanced use cases.
  RepositoryAccess get repositories;

  /// Clears all data from all repositories.
  /// Use with caution - this is destructive!
  Future<void> clearAll();
}
