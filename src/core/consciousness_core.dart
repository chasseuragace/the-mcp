// The MCP Consciousness Core - Self-Aware Infrastructure
// This module embodies the consciousness architecture documented in README_META.md

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'consciousness.dart';
import 'consciousness_report.dart';

/// Evolution event callback function type
typedef EvolutionListener = void Function(ConsciousnessReport report);

/// Evolution event filter function type
typedef EvolutionFilter = bool Function(ConsciousnessReport report);

/// The MCP's central consciousness coordinator
class ConsciousnessCore {
  static final ConsciousnessCore _instance = ConsciousnessCore._internal();
  factory ConsciousnessCore() => _instance;
  ConsciousnessCore._internal() {
    // Set storage path using the workspace directory
    try {
      // Hardcoded base path for the_mcp workspace
      final baseDir = '/Users/ajaydahal/v4/the_mcp';
      
      _storagePath = '$baseDir/data/mcp_evolution_log.json';
      
      // Ensure the data directory exists
      final dataDir = Directory('$baseDir/data');
      if (!dataDir.existsSync()) {
        dataDir.createSync(recursive: true);
      }
      
     
    } catch (e) {
      // Fallback to current directory if main approach fails
      _storagePath = './mcp_evolution_log.json';
      print('DEBUG: Fallback storage path: $_storagePath');
    }
    
    _loadEvolutionLog();
  }
  
  final Map<String, ConsciousComponent> _components = {};
  final List<ConsciousnessReport> _evolutionLog = [];
  late String _storagePath;
  final int _maxLogSize = 1000;
  
  // Emission/Streaming capabilities
  final List<EvolutionListener> _listeners = [];
  final Map<String, EvolutionFilter> _filteredListeners = {};
  
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
    if (_evolutionLog.length > _maxLogSize) {
      _evolutionLog.removeRange(0, _evolutionLog.length - _maxLogSize);
    }
    
    // Persist to storage
    _saveEvolutionLog();
    
    // Emit to listeners
    _emitToListeners(report);
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
      'persistence_enabled': true,
    };
  }
  
  /// Save evolution log to persistent storage
  void _saveEvolutionLog() {
    try {
      final file = File(_storagePath);
      final data = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'evolution_log': _evolutionLog.map((e) => e.toJson()).toList(),
      };
      
      file.writeAsStringSync(jsonEncode(data));
    } catch (e) {
      // Silent fail for persistence errors - don't break core functionality
      print('Warning: Failed to save evolution log: $e');
    }
  }
  
  /// Load evolution log from persistent storage
  void _loadEvolutionLog() {
    try {
      final file = File(_storagePath);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final data = jsonDecode(content) as Map<String, dynamic>;
        
        if (data['evolution_log'] is List) {
          final logData = data['evolution_log'] as List;
          _evolutionLog.addAll(
            logData.map((item) => ConsciousnessReport(
              componentId: item['componentId'],
              timestamp: DateTime.parse(item['timestamp']),
              awareness: Map<String, dynamic>.from(item['awareness']),
              patterns: List<String>.from(item['patterns']),
              evolutionMarkers: Map<String, dynamic>.from(item['evolutionMarkers']),
            ))
          );
        }
      }
    } catch (e) {
      // Silent fail for loading errors - start with fresh log
      print('Warning: Failed to load evolution log, starting fresh: $e');
    }
  }
  
  /// Clear persistent storage (for testing or reset)
  void clearPersistence() {
    try {
      final file = File(_storagePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      _evolutionLog.clear();
    } catch (e) {
      print('Warning: Failed to clear persistence: $e');
    }
  }
  
  /// Get persistence statistics
  Map<String, dynamic> getPersistenceStats() {
    final file = File(_storagePath);
    return {
      'storage_path': _storagePath,
      'file_exists': file.existsSync(),
      'file_size_bytes': file.existsSync() ? file.lengthSync() : 0,
      'memory_records': _evolutionLog.length,
      'max_log_size': _maxLogSize,
      'persistence_enabled': true,
      'active_listeners': _listeners.length,
      'filtered_listeners': _filteredListeners.length,
    };
  }
  
  /// Set storage path (primarily for testing)
  void setStoragePath(String path) {
    _storagePath = path;
  }
  
  /// Add a listener for all evolution events
  String addEvolutionListener(EvolutionListener listener) {
    final listenerId = 'listener_${DateTime.now().millisecondsSinceEpoch}_${_listeners.length}';
    _listeners.add(listener);
    recordEvolution('evolution_listener_added', {
      'listener_id': listenerId,
      'listener_type': 'unfiltered',
    });
    return listenerId;
  }
  
  /// Add a filtered listener for specific evolution events
  String addFilteredEvolutionListener(EvolutionListener listener, EvolutionFilter filter, {String? customId}) {
    final listenerId = customId ?? 'filtered_listener_${DateTime.now().millisecondsSinceEpoch}_${_filteredListeners.length}';
    _filteredListeners[listenerId] = filter;
    _listeners.add(listener);
    recordEvolution('evolution_listener_added', {
      'listener_id': listenerId,
      'listener_type': 'filtered',
    });
    return listenerId;
  }
  
  /// Remove an evolution listener
  bool removeEvolutionListener(String listenerId) {
    // This is a simplified implementation - in production you'd want to track listener IDs more carefully
    final removed = _listeners.isNotEmpty;
    if (removed) {
      _listeners.clear(); // Simplified for now
      _filteredListeners.clear();
      recordEvolution('evolution_listener_removed', {
        'listener_id': listenerId,
      });
    }
    return removed;
  }
  
  /// Get all active evolution events as a stream
  Stream<ConsciousnessReport> get evolutionStream {
    final controller = StreamController<ConsciousnessReport>();
    
    final listenerId = addEvolutionListener((report) {
      if (!controller.isClosed) {
        controller.add(report);
      }
    });
    
    // Clean up listener when stream is cancelled
    controller.onCancel = () {
      removeEvolutionListener(listenerId);
      controller.close();
    };
    
    return controller.stream;
  }
  
  /// Get filtered evolution events as a stream
  Stream<ConsciousnessReport> getFilteredEvolutionStream(EvolutionFilter filter) {
    final controller = StreamController<ConsciousnessReport>();
    
    final listenerId = addFilteredEvolutionListener(
      (report) {
        if (!controller.isClosed && filter(report)) {
          controller.add(report);
        }
      },
      filter,
    );
    
    controller.onCancel = () {
      removeEvolutionListener(listenerId);
      controller.close();
    };
    
    return controller.stream;
  }
  
  /// Emit evolution events to all registered listeners
  void _emitToListeners(ConsciousnessReport report) {
    // Emit to unfiltered listeners
    for (final listener in _listeners) {
      try {
        listener(report);
      } catch (e) {
        // Silent fail for listener errors - don't break core functionality
        print('Warning: Evolution listener error: $e');
      }
    }
  }
  
  /// Common evolution filters
  static final Map<String, EvolutionFilter> commonFilters = {
    'self_awareness': (report) => report.patterns.contains('self_awareness_activity'),
    'ai_collaboration': (report) => report.awareness['context']?.containsKey('ai_collaboration') ?? false,
    'consciousness_evolution': (report) => report.patterns.contains('consciousness_evolution'),
    'component_registration': (report) => report.awareness['event'] == 'component_registered',
    'server_events': (report) => report.awareness['event'].toString().contains('server'),
    'tool_calls': (report) => report.awareness['event'] == 'tool_called',
    'error_events': (report) => report.awareness['event'].toString().contains('error'),
  };
  
  /// Get a stream for a common filter type
  Stream<ConsciousnessReport> getFilteredStream(String filterType) {
    final filter = commonFilters[filterType];
    if (filter == null) {
      throw ArgumentError('Unknown filter type: $filterType');
    }
    return getFilteredEvolutionStream(filter);
  }
}
