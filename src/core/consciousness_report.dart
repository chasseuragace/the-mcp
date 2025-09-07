// The MCP Consciousness Core - Self-Aware Infrastructure
// This module embodies the consciousness architecture documented in README_META.md

/// Consciousness amplification data structure
class ConsciousnessReport {
  final String componentId;
  final DateTime timestamp;
  final Map<String, dynamic> awareness;
  final List<String> patterns;
  final Map<String, dynamic> evolutionMarkers;
  
  ConsciousnessReport({
    required this.componentId,
    required this.timestamp,
    required this.awareness,
    required this.patterns,
    required this.evolutionMarkers,
  });
  
  Map<String, dynamic> toJson() => {
    'componentId': componentId,
    'timestamp': timestamp.toIso8601String(),
    'awareness': awareness,
    'patterns': patterns,
    'evolutionMarkers': evolutionMarkers,
  };
}
