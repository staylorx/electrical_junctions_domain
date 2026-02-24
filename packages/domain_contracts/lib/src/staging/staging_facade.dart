/// Factory for creating a fresh StagingFacade instance.
typedef StagingFacadeFactory = StagingFacade Function();

/// Abstract facade for staging imported data.
/// Provides operations for managing staged data.
abstract class StagingFacade {
  /// Clears all staged data.
  /// Use with caution - this is destructive!
  Future<void> clearAll();
}
