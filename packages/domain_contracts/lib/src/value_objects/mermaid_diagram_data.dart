/// Structured data for a Mermaid diagram.
///
/// Contains devices, their properties, and relationships for generating
/// class diagrams without presentation formatting.
class MermaidDiagramData {
  final List<MermaidDevice> devices;
  final List<MermaidRelationship> relationships;
  final List<MermaidPanel> panels;

  const MermaidDiagramData({
    required this.devices,
    required this.relationships,
    required this.panels,
  });
}

class MermaidDevice {
  final String className;
  final String name;
  final String typeId;
  final int? amperage;
  final int? poles;

  const MermaidDevice({
    required this.className,
    required this.name,
    required this.typeId,
    this.amperage,
    this.poles,
  });
}

class MermaidRelationship {
  final String sourceClass;
  final String targetClass;

  const MermaidRelationship({
    required this.sourceClass,
    required this.targetClass,
  });
}

class MermaidPanel {
  final String panelClass;
  final List<String> circuitBreakerClasses;

  const MermaidPanel({
    required this.panelClass,
    required this.circuitBreakerClasses,
  });
}