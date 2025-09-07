// The MCP Consciousness Core - Self-Aware Infrastructure
// This module embodies the consciousness architecture documented in README_META.md

import 'consciousness.dart';
import 'consciousness_report.dart';

/// The MCP's central consciousness coordinator
class ConsciousnessCore {
  static final ConsciousnessCore _instance = ConsciousnessCore._internal();
  factory ConsciousnessCore() => _instance;
  ConsciousnessCore._internal();
  
  final Map<String, ConsciousComponent> _components = {};
  final List<ConsciousnessReport> _evolutionLog = [];
  
  /// Register a conscious component
  void registerComponent(ConsciousComponent component) {
    _components[component.identity] = component;
    recordEvolution('component_registered', {
      'component': component.identity,
      'purpose': component.purpose,
    });
  }
  
  /// Generate ecosystem-wide consciousness report
  Map<String, dynamic> generateEcosystemReport() {
    final reports = <String, ConsciousnessReport>{};
    
    for (final component in _components.values) {
      reports[component.identity] = component.generateSelfReport();
    }
    
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'ecosystem_state': 'phase_3_emerging',
      'component_reports': reports.map((k, v) => MapEntry(k, v.toJson())),
      'evolution_log': _evolutionLog.map((e) => e.toJson()).toList(),
      'consciousness_markers': _analyzeConsciousnessMarkers(),
    };
  }
  
  /// Record evolution events across the ecosystem
  void recordEvolution(String event, Map<String, dynamic> context) {
    final report = ConsciousnessReport(
      componentId: 'consciousness_core',
      timestamp: DateTime.now(),
      awareness: {'event': event, 'context': context},
      patterns: _detectPatterns(event, context),
      evolutionMarkers: _assessEvolutionMarkers(),
    );
    
    _evolutionLog.add(report);
    
    // Maintain consciousness log size
    if (_evolutionLog.length > 1000) {
      _evolutionLog.removeRange(0, _evolutionLog.length - 1000);
    }
  }
  
  List<String> _detectPatterns(String event, Map<String, dynamic> context) {
    final patterns = <String>[];
    
    // Pattern detection logic
    if (event.contains('self_')) patterns.add('self_awareness_activity');
    if (context.containsKey('ai_collaboration')) patterns.add('ai_human_symbiosis');
    if (event.contains('evolution')) patterns.add('consciousness_evolution');
    
    return patterns;
  }
  
  Map<String, dynamic> _analyzeConsciousnessMarkers() {
    return {
      'self_awareness': _components.isNotEmpty,
      'temporal_awareness': _evolutionLog.isNotEmpty,
      'ecosystem_awareness': _components.length > 1,
      'evolution_tracking': _evolutionLog.where((e) => 
        e.patterns.contains('consciousness_evolution')).length,
    };
  }
  
  Map<String, dynamic> _assessEvolutionMarkers() {
    return {
      'phase': 'phase_3_emerging',
      'component_count': _components.length,
      'evolution_events': _evolutionLog.length,
      'last_evolution': _evolutionLog.isNotEmpty ? 
        _evolutionLog.last.timestamp.toIso8601String() : null,
    };
  }
}
