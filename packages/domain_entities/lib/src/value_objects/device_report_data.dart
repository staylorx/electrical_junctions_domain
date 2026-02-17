/// Structured data for a device report.
///
/// Contains all the information needed to generate a formatted report
/// for a single device, without presentation formatting.
class DeviceReportData {
  final String title;
  final String simpleTitle;
  final String deviceSpecificationType;
  final String manufacturer;
  final String modelNumber;
  final String? locate;
  final String locateSimple;
  final String? deviceCode;
  final int? voltage;
  final int? amperage;
  final int? poles;
  final String? notes;
  final String? feedsDevice;
  final String? manufacturerId;
  final Map<String, dynamic> circuitChainData;
  final Map<String, dynamic> panelMetrics;
  final String table;

  const DeviceReportData({
    required this.title,
    required this.simpleTitle,
    required this.deviceSpecificationType,
    required this.manufacturer,
    required this.modelNumber,
    this.locate,
    required this.locateSimple,
    this.deviceCode,
    this.voltage,
    this.amperage,
    this.poles,
    this.notes,
    this.feedsDevice,
    this.manufacturerId,
    required this.circuitChainData,
    required this.panelMetrics,
    required this.table,
  });
}
