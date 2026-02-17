/// Result of an export operation.
/// Contains the exported data in the requested format.
class ExportResult {
  /// The exported content as a string (for CSV format).
  final String? stringContent;

  /// The exported content as bytes (for Excel format).
  final List<int>? bytesContent;

  const ExportResult.string(String content)
    : stringContent = content,
      bytesContent = null;

  const ExportResult.bytes(List<int> bytes)
    : stringContent = null,
      bytesContent = bytes;

  /// Whether this result contains string content.
  bool get isString => stringContent != null;

  /// Whether this result contains bytes content.
  bool get isBytes => bytesContent != null;
}
