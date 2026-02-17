import 'package:electrical_junctions_contracts/index.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the `GenerateDeviceReportsUseCase` class.
class GenerateDeviceReportsUseCase {
  final DeviceRepository deviceRepository;
  final CircuitRepository circuitRepository;
  final LocateRepository locateRepository;
  final ManufacturerRepository? manufacturerRepository;
  final DeviceReportConfiguration configuration;

  GenerateDeviceReportsUseCase({
    required this.deviceRepository,
    required this.circuitRepository,
    required this.locateRepository,
    this.manufacturerRepository,
    DeviceReportConfiguration? configuration,
  }) : configuration = configuration ?? const DeviceReportConfiguration();

  TaskEither<Failure, List<DeviceReportData>> call() {
    return deviceRepository.getAll().flatMap((devices) {
      return circuitRepository.getAll().flatMap((circuits) {
        return TaskEither(() async {
          final reports = <DeviceReportData>[];

          /// Executes `for`.
          for (final device in devices) {
            final data = await _generateReport(
              device: device,
              circuits: circuits,
            );

            if (data != null) {
              reports.add(data);
            }
          }

          return Right(reports);
        });
      });
    });
  }

  /// Executes `_generateReport`.
  Future<DeviceReportData?> _generateReport({
    required Device device,
    required List<Circuit> circuits,
  }) async {
    final typeId = device.deviceSpecification.typeId;

    // Skip devices not in configuration
    if (!configuration.includedTypes.contains(typeId)) {
      return null;
    }

    // Simple title: use modelNumber for most devices, location name for transformers/meters
    final simpleTitle = _getSimpleTitle(device);

    final data = <String, dynamic>{
      'title':
          device.name ??
          '${device.locate?.name.split('.').first ?? 'unknown'} ${device.deviceSpecification.typeId.toUpperCase()}',
      'simpleTitle': simpleTitle,
      'deviceSpecificationType': device.deviceSpecification.typeId,
      'manufacturer': device.deviceSpecification.manufacturer.name,
      'modelNumber': device.deviceSpecification.modelNumber,
      'locate': await _buildLocationPath(device.locate),
      'locateSimple': device.locate?.toString() ?? 'Unknown',
      'deviceCode': device.name,
      'voltage': device.deviceSpecification.safeGetProperty<int>('voltage'),
      'amperage': device.deviceSpecification.safeGetProperty<int>('ampRating'),
      'poles': device.deviceSpecification.safeGetProperty<int>('poleCount'),
      'notes': null, // Placeholder for device-specific notes
      'feedsDevice': null, // Placeholder for meter feeds information
    };

    // Add manufacturer ID if configured
    if (configuration.includeManufacturerDetails &&
        manufacturerRepository != null) {
      data['manufacturerId'] =
          device.deviceSpecification.manufacturer.handle.value;
    }

    // Add circuit chain data if configured
    data.addAll(_buildCircuitChainData(device: device, circuits: circuits));

    // Add panel metrics if configured and device is a panel
    data.addAll(_calculatePanelMetrics(panel: device, circuits: circuits));

    final table = device.deviceSpecification.typeId == 'panel'
        ? await _generatePanelTableString(panel: device, circuits: circuits)
        : _generateDeviceTableString(device: device, circuits: circuits);

    return DeviceReportData(
      title: data['title'] as String,
      simpleTitle: data['simpleTitle'] as String,
      deviceSpecificationType: data['deviceSpecificationType'] as String,
      manufacturer: data['manufacturer'] as String,
      modelNumber: data['modelNumber'] as String,
      locate: data['locate'] as String?,
      locateSimple: data['locateSimple'] as String,
      deviceCode: data['deviceCode'] as String?,
      voltage: data['voltage'] as int?,
      amperage: data['amperage'] as int?,
      poles: data['poles'] as int?,
      notes: data['notes'] as String?,
      feedsDevice: data['feedsDevice'] as String?,
      manufacturerId: data['manufacturerId'] as String?,
      circuitChainData: _buildCircuitChainData(device: device, circuits: circuits),
      panelMetrics: _calculatePanelMetrics(panel: device, circuits: circuits),
      table: table,
    );
  }

  Future<String> _generatePanelTableString({
    required Device panel,
    required List<Circuit> circuits,
  }) async {
    // Validate panel is a Panel
    assert(
      panel.deviceSpecification.typeId == 'panel',
      'Device must be a Panel',
    );

    // Fetch slots - find all panel_slot circuits for this panel
    final slots = circuits
        .where(
          (c) =>
              c.stereoType == 'panel_slot' &&
              c.sourceDevice.handle.value == panel.handle.value,
        )
        .toList();

    // Create a map of slot code -> circuit for quick lookup
    final slotMap = <String, Circuit>{};
    for (final slot in slots) {
      slotMap[slot.name ?? ''] = slot;
    }

    // Determine if this is a GE panel (uses A/B format)
    final isGE =
        panel.deviceSpecification.manufacturer.name == 'GE' ||
        slots.any(
          (s) => (s.name ?? '').contains('A') || (s.name ?? '').contains('B'),
        );

    // Get configured slot count from metadata, or use actual slot count
    final configuredSlotCount = panel.deviceSpecification.safeGetProperty<int>(
      'slotCount',
    );
    final actualSlotCount = slots.length;
    final totalSlots = configuredSlotCount ?? actualSlotCount;

    // Generate all slot codes based on panel type
    final allSlotCodes = <String>[];
    if (isGE && totalSlots > 0) {
      // GE format: 1A, 1B, 2A, 2B, etc.
      // For a 24-slot panel, we have positions 1-12, each with A and B
      final positions = (totalSlots / 2).ceil();
      for (int pos = 1; pos <= positions; pos++) {
        allSlotCodes.add('${pos}A');
        allSlotCodes.add('${pos}B');
      }
    } else {
      // Standard numeric format: 1, 2, 3, etc.
      for (int i = 1; i <= totalSlots; i++) {
        allSlotCodes.add('$i');
      }
    }

    // Generate slot lines for all slots
    final slotLines = <String>[];
    for (final slotCode in allSlotCodes) {
      final slot = slotMap[slotCode];
      final circuitBreaker = slot?.connectedDevices.isNotEmpty ?? false
          ? slot!.connectedDevices.first
          : null;
      final circuitStr = _getCircuitString(
        breaker: circuitBreaker,
        circuits: circuits,
      );
      slotLines.add('$slotCode: $circuitStr');
    }

    // Two-column table with GE-style odd/even layout
    final buffer = StringBuffer();
    buffer.writeln('| Slot: Circuit                  | Slot: Circuit   |');
    buffer.writeln('| ------------------------------ | --------------- |');

    if (isGE && slotLines.isNotEmpty) {
      // GE panels: odd numbers in left column, even in right
      // E.g., Left: 1A, 1B, 3A, 3B, 5A, 5B...  Right: 2A, 2B, 4A, 4B, 6A, 6B...
      final positions = (totalSlots / 2).ceil();
      for (int pos = 1; pos <= positions; pos += 2) {
        final oddPos = pos;
        final evenPos = pos + 1;

        // Left column: odd position A and B
        final leftA = slotLines.firstWhere(
          (s) => s.startsWith('${oddPos}A:'),
          orElse: () => '',
        );
        final leftB = slotLines.firstWhere(
          (s) => s.startsWith('${oddPos}B:'),
          orElse: () => '',
        );

        // Right column: even position A and B
        final rightA = evenPos <= positions
            ? slotLines.firstWhere(
                (s) => s.startsWith('${evenPos}A:'),
                orElse: () => '',
              )
            : '';
        final rightB = evenPos <= positions
            ? slotLines.firstWhere(
                (s) => s.startsWith('${evenPos}B:'),
                orElse: () => '',
              )
            : '';

        if (leftA.isNotEmpty || rightA.isNotEmpty) {
          buffer.writeln('| ${leftA.padRight(30)} | ${rightA.padRight(15)} |');
        }
        if (leftB.isNotEmpty || rightB.isNotEmpty) {
          buffer.writeln('| ${leftB.padRight(30)} | ${rightB.padRight(15)} |');
        }
      }
    } else {
      // Standard sequential layout for non-GE panels
      for (int i = 0; i < slotLines.length; i += 2) {
        final left = slotLines[i];
        final right = i + 1 < slotLines.length ? slotLines[i + 1] : '';
        buffer.writeln('| ${left.padRight(30)} | ${right.padRight(15)} |');
      }
    }

    return buffer.toString();
  }

  /// Executes `_generateDeviceTableString`.
  String _generateDeviceTableString({
    required Device device,
    required List<Circuit> circuits,
  }) {
    // Find circuits where device is connected
    final deviceCircuits = circuits
        .where((c) => c.connectedDevices.any((d) => d.name == device.name))
        .toList();

    final slotLines = <String>[];

    /// Executes `for`.
    for (final circuit in deviceCircuits) {
      if (circuit.sourceDevice.deviceSpecification.typeId !=
          'circuit_breaker') {
        continue;
      }
      final breaker = circuit.sourceDevice;
      final circuitStr = _getCircuitString(
        breaker: breaker,
        circuits: circuits,
      );
      final poles =
          breaker.deviceSpecification.safeGetProperty<int>('poleCount') ?? 1;
      final isGE =
          device.deviceSpecification.manufacturer.name == 'GE' ||
          device.deviceSpecification.typeId == 'ups';
      final slotCodes = _getSlotCodes(poles: poles, isGE: isGE);
      final notations = _getNotations(poles: poles);
      for (int i = 0; i < slotCodes.length; i++) {
        final start = notations[i];
        final end = notations[notations.length - 1 - i];
        slotLines.add('${slotCodes[i]}: $start$circuitStr$end');
      }
    }

    // Single column table
    final buffer = StringBuffer();
    buffer.writeln('| Slot: Circuit      |');
    buffer.writeln('| ------------------ |');

    /// Executes `for`.
    for (final line in slotLines) {
      buffer.writeln('| ${line.padRight(18)} |');
    }
    return buffer.toString();
  }

  /// Executes `_getCircuitString`.
  String _getCircuitString({
    required Device? breaker,
    required List<Circuit> circuits,
  }) {
    if (breaker == null) return '';

    // Validate breaker is a CircuitBreaker
    assert(
      breaker.deviceSpecification.typeId == 'circuit_breaker',
      'Device must be a CircuitBreaker',
    );

    final breakerCircuits = circuits
        .where(
          (c) =>
              c.stereoType != 'panel_slot' &&
              c.sourceDevice.handle.value == breaker.handle.value,
        )
        .toList();
    final circuit = breakerCircuits.isNotEmpty ? breakerCircuits.first : null;

    // Build circuit string with amperage and circuit name
    final ampRating =
        breaker.deviceSpecification.safeGetProperty<int>('ampRating') ??
        'Unknown';
    final circuitName = circuit?.name ?? '';
    final circuitBase = circuitName.isNotEmpty
        ? '${ampRating}A $circuitName'
        : '${ampRating}A unknown circuit';

    final poles =
        breaker.deviceSpecification.safeGetProperty<int>('poleCount') ?? 1;
    if (poles == 1) return circuitBase;
    final notations = _getNotations(poles: poles);
    return '${notations[0]}$circuitBase${notations[1]}';
  }

  /// Executes `_getSlotCodes`.
  List<String> _getSlotCodes({required int poles, required bool isGE}) {
    /// Executes `if`.
    if (isGE) {
      return List.generate(poles, (i) => '${i + 1}${i == 0 ? 'A' : 'B'}');
    } else {
      return List.generate(poles, (i) => '${i + 1}');
    }
  }

  /// Executes `_getNotations`.
  List<String> _getNotations({required int poles}) {
    if (poles <= 1) return ['', ''];
    if (poles == 2) return ['/', '\\'];
    // For poles > 2, first is '/', last is '\', middles are '='
    final list = <String>['/'];
    for (int i = 1; i < poles - 1; i++) {
      list.add('=');
    }
    list.add('\\');
    return list;
  }

  /// Builds full location hierarchy path (e.g., "Building > Floor > Room").
  Future<String> _buildLocationPath(Locate? locate) async {
    if (locate == null) return 'Unknown';

    if (!configuration.includeLocationHierarchy) {
      return locate.name;
    }

    // Build full hierarchy path
    final path = <String>[];
    Locate? current = locate;

    while (current != null) {
      path.insert(0, current.name);
      final parentResult = await locateRepository.findParent(current).run();
      current = parentResult.getOrElse((_) => null);
    }

    return path.join(' > ');
  }

  /// Traces upstream power flow (what feeds this device).
  List<String> _traceUpstream({
    required Device device,
    required List<Circuit> circuits,
  }) {
    final chain = <String>[];
    Device? current = device;
    final visited = <String>{};

    while (current != null && !visited.contains(current.handle.value)) {
      visited.add(current.handle.value);

      // Find circuit where current device is connected
      final feedingCircuit = circuits.cast<Circuit?>().firstWhere(
        (c) =>
            c != null &&
            c.connectedDevices.any(
              (d) => d.handle.value == current!.handle.value,
            ),
        orElse: () => null,
      );

      if (feedingCircuit != null) {
        chain.insert(0, feedingCircuit.sourceDevice.name ?? 'Unknown');
        current = feedingCircuit.sourceDevice;
      } else {
        current = null;
      }
    }

    return chain;
  }

  /// Traces downstream power flow (what this device feeds).
  List<String> _traceDownstream({
    required Device device,
    required List<Circuit> circuits,
  }) {
    final downstream = <String>[];
    final directCircuits = circuits.where(
      (c) =>
          c.sourceDevice.handle.value == device.handle.value &&
          c.stereoType != 'panel_slot',
    );

    for (final circuit in directCircuits) {
      for (final connected in circuit.connectedDevices) {
        downstream.add(connected.name ?? 'Unknown');
      }
    }

    return downstream;
  }

  /// Builds circuit chain data for power flow visualization.
  Map<String, dynamic> _buildCircuitChainData({
    required Device device,
    required List<Circuit> circuits,
  }) {
    if (!configuration.includeCircuitChains) {
      // Return null values so Mustache {{#field}} conditionals work correctly
      return {'upstream': null, 'downstream': null, 'powerFlowChain': null};
    }

    final upstream = _traceUpstream(device: device, circuits: circuits);
    final downstream = _traceDownstream(device: device, circuits: circuits);

    final upstreamStr = upstream.isEmpty ? 'Source' : upstream.join(' → ');
    final downstreamStr = downstream.isEmpty ? 'None' : downstream.join(', ');

    return {
      'upstream': upstream,
      'downstream': downstream,
      'powerFlowChain': upstream.isEmpty
          ? '${device.name} → $downstreamStr'
          : '$upstreamStr → ${device.name} → $downstreamStr',
    };
  }

  /// Gets a simple title for the device report.
  /// For panels: modelNumber (e.g., "PNL-001")
  /// For transformers/meters: location name (e.g., "Orleans")
  /// For others: modelNumber
  String _getSimpleTitle(Device device) {
    final type = device.deviceSpecification.typeId;

    if (type == 'transformer' || type == 'meter') {
      // Use first part of location for transformers and meters
      return device.locate?.name.split('.').first ?? 'Unknown';
    }

    // For all other devices, use model number
    return device.deviceSpecification.modelNumber;
  }



  /// Calculates panel utilization metrics.
  Map<String, dynamic> _calculatePanelMetrics({
    required Device panel,
    required List<Circuit> circuits,
  }) {
    if (panel.deviceSpecification.typeId != 'panel') {
      return {
        'totalSlots': null,
        'usedSlots': null,
        'emptySlots': null,
        'totalBreakerLoad': null,
        'panelRating': null,
        'utilizationPercent': null,
        'availableCapacity': null,
      };
    }

    if (!configuration.includeCrossPanelMetrics) {
      return {
        'totalSlots': null,
        'usedSlots': null,
        'emptySlots': null,
        'totalBreakerLoad': null,
        'panelRating': null,
        'utilizationPercent': null,
        'availableCapacity': null,
      };
    }

    final panelRating =
        panel.deviceSpecification.safeGetProperty<int>('ampRating') ?? 0;

    // Find all slots for this panel
    final slots = circuits
        .where(
          (c) =>
              c.stereoType == 'panel_slot' &&
              c.sourceDevice.handle.value == panel.handle.value,
        )
        .toList();

    // Get configured slot count from metadata if available
    final configuredSlotCount = panel.deviceSpecification.safeGetProperty<int>(
      'slotCount',
    );

    int totalBreakerLoad = 0;
    int usedSlots = 0;
    int emptySlots = 0;

    for (final slot in slots) {
      if (slot.connectedDevices.isNotEmpty) {
        usedSlots++;
        final breaker = slot.connectedDevices.first;
        totalBreakerLoad +=
            breaker.deviceSpecification.safeGetProperty<int>('ampRating') ?? 0;
      } else {
        emptySlots++;
      }
    }

    // Use configured count if available, otherwise count actual slots
    final totalSlots = configuredSlotCount ?? slots.length;

    // Calculate truly empty slots considering configured slot count
    final actualEmptySlots = configuredSlotCount != null
        ? (configuredSlotCount - usedSlots).clamp(0, configuredSlotCount)
        : emptySlots;

    final utilizationPercent = panelRating > 0
        ? (totalBreakerLoad / panelRating * 100).toStringAsFixed(1)
        : '0.0';

    return {
      'totalSlots': totalSlots,
      'usedSlots': usedSlots,
      'emptySlots': actualEmptySlots,
      'totalBreakerLoad': totalBreakerLoad,
      'panelRating': panelRating,
      'utilizationPercent': utilizationPercent,
      'availableCapacity': panelRating - totalBreakerLoad,
    };
  }
}
