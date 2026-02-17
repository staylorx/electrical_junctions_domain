/// Configuration for device report generation.
///
/// Controls which device types are included in reports and which
/// enrichment features are enabled (location hierarchy, circuit chains,
/// manufacturer details, and cross-panel metrics).
class DeviceReportConfiguration {
  /// Device types to include in reports.
  final Set<String> includedTypes;

  /// Whether to build full location hierarchy (e.g., "Building > Floor > Room").
  final bool includeLocationHierarchy;

  /// Whether to trace circuit connections (upstream/downstream).
  final bool includeCircuitChains;

  /// Whether to include detailed manufacturer information.
  final bool includeManufacturerDetails;

  /// Whether to calculate panel utilization metrics.
  final bool includeCrossPanelMetrics;

  /// Optional custom templates directory path.
  /// If provided, templates in this directory will override default templates.
  final String? templatesDir;

  const DeviceReportConfiguration({
    Set<String>? includedTypes,
    this.includeLocationHierarchy = false,
    this.includeCircuitChains = false,
    this.includeManufacturerDetails = false,
    this.includeCrossPanelMetrics = false,
    this.templatesDir,
  }) : includedTypes = includedTypes ?? _defaultTypes;

  /// Default device types.
  static const _defaultTypes = {'panel', 'transformer', 'meter', 'ups'};

  /// Factory for comprehensive enrichment with all features enabled.
  factory DeviceReportConfiguration.enriched({
    Set<String>? types,
    String? templatesDir,
  }) => DeviceReportConfiguration(
    includedTypes:
        types ??
        const {
          'panel',
          'transformer',
          'meter',
          'ups',
          'circuit_breaker',
          'receptacle',
          'switch',
          'appliance',
          'gfci',
          'afci',
          'fuse',
          'junction_box',
        },
    includeLocationHierarchy: true,
    includeCircuitChains: true,
    includeManufacturerDetails: true,
    includeCrossPanelMetrics: true,
    templatesDir: templatesDir,
  );
}