/// Export mode options for data layout
enum ExportMode {
  /// Denormalized format - all related data inline in each row (default)
  denormalized,

  /// Normalized format - separate sheets/files like import format
  normalized,
}
