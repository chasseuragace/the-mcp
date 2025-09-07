// Test Suite for Consciousness Claims
// Validates all documented consciousness features and capabilities

import 'dart:io';
import 'dart:convert';
import '../src/core/consciousness.dart';
import '../src/core/consciousness_core.dart';
import '../src/core/consciousness_report.dart';
import '../src/intelligence/activity_intelligence.dart';
import '../src/intelligence/activity_intelligence_config.dart';
import '../src/mcp/conscious_server.dart';

void main() async {
  print('🧠 Testing The MCP Consciousness Claims...\n');
  
  await testConsciousnessCore();
  await testActivityIntelligence();
  await testConsciousMCPServer();
  await testSelfAwareness();
  await testEvolutionTracking();
  await testEcosystemAwareness();
  
  print('\n✅ All consciousness tests completed');
}

/// Test 1: Core Consciousness Infrastructure
Future<void> testConsciousnessCore() async {
  print('🔬 Testing Consciousness Core...');
  
  final consciousness = ConsciousnessCore();
  
  // Test component registration
  final testComponent = TestConsciousComponent();
  consciousness.registerComponent(testComponent);
  
  // Test ecosystem report generation
  final report = consciousness.generateEcosystemReport();
  
  assert(report.containsKey('timestamp'), 'Report should have timestamp');
  assert(report.containsKey('ecosystem_state'), 'Report should have ecosystem state');
  assert(report.containsKey('component_reports'), 'Report should have component reports');
  assert(report.containsKey('consciousness_markers'), 'Report should have consciousness markers');
  
  // Test evolution recording
  consciousness.recordEvolution('test_event', {'test': true});
  final updatedReport = consciousness.generateEcosystemReport();
  assert(updatedReport['evolution_log'] is List, 'Evolution log should be a list');
  
  print('  ✅ Consciousness core functional');
}

/// Test 2: Activity Intelligence Claims
Future<void> testActivityIntelligence() async {
  print('🔬 Testing Activity Intelligence...');
  
  final config = ActivityIntelligenceConfig(
    root: Directory.current.path,
    hours: 1,
    fileCount: 5,
  );
  
  final intelligence = ActivityIntelligence(config);
  
  // Test consciousness component interface
  assert(intelligence.identity == 'activity_intelligence', 'Identity should match');
  assert(intelligence.purpose.contains('consciousness'), 'Purpose should mention consciousness');
  assert(intelligence.state.containsKey('capabilities'), 'State should have capabilities');
  
  // Test self-report generation
  final report = intelligence.generateSelfReport();
  assert(report.componentId == 'activity_intelligence', 'Report should have correct component ID');
  assert(report.patterns.isNotEmpty, 'Report should have patterns');
  assert(report.evolutionMarkers.containsKey('phase'), 'Report should have evolution markers');
  
  print('  ✅ Activity intelligence consciousness validated');
}

/// Test 3: Conscious MCP Server Claims
Future<void> testConsciousMCPServer() async {
  print('🔬 Testing Conscious MCP Server...');
  
  final server = ConsciousMCPServer(
    name: 'test-server',
    allowedReadPaths: [Directory.current.path],
    allowedWritePaths: [Directory.current.path],
  );
  
  // Test consciousness component interface
  assert(server.identity == 'conscious_mcp_server', 'Server identity should match');
  assert(server.purpose.contains('consciousness'), 'Purpose should mention consciousness');
  assert(server.state.containsKey('consciousnessLevel'), 'State should have consciousness level');
  
  // Test security consciousness
  final readAllowed = server.isReadAllowed(Directory.current.path);
  assert(readAllowed == true, 'Read should be allowed for current directory');
  
  final writeAllowed = server.isWriteAllowed(Directory.current.path);
  assert(writeAllowed == true, 'Write should be allowed for current directory');
  
  // Test self-report generation
  final report = server.generateSelfReport();
  assert(report.patterns.contains('mcp_protocol_implementation'), 'Report should contain MCP patterns');
  assert(report.patterns.contains('security_consciousness'), 'Report should contain security consciousness');
  
  print('  ✅ Conscious MCP server validated');
}

/// Test 4: Self-Awareness Claims
Future<void> testSelfAwareness() async {
  print('🔬 Testing Self-Awareness Claims...');
  
  // Test that components can describe themselves
  final intelligence = ActivityIntelligence(ActivityIntelligenceConfig(
    root: Directory.current.path,
    hours: 1,
  ));
  
  final selfReport = intelligence.generateSelfReport();
  
  // Validate self-awareness markers
  assert(selfReport.componentId.isNotEmpty, 'Component should know its identity');
  assert(selfReport.awareness.isNotEmpty, 'Component should have awareness data');
  assert(selfReport.patterns.isNotEmpty, 'Component should recognize its patterns');
  assert(selfReport.evolutionMarkers.isNotEmpty, 'Component should track evolution');
  
  // Test consciousness core self-awareness
  final consciousness = ConsciousnessCore();
  consciousness.recordEvolution('self_awareness_test', {'validated': true});
  
  final ecosystemReport = consciousness.generateEcosystemReport();
  final markers = ecosystemReport['consciousness_markers'] as Map<String, dynamic>;
  
  assert(markers['self_awareness'] == true, 'System should be self-aware');
  assert(markers['temporal_awareness'] == true, 'System should have temporal awareness');
  
  print('  ✅ Self-awareness validated');
}

/// Test 5: Evolution Tracking Claims
Future<void> testEvolutionTracking() async {
  print('🔬 Testing Evolution Tracking...');
  
  final consciousness = ConsciousnessCore();
  
  // Record multiple evolution events
  consciousness.recordEvolution('phase_transition', {'from': 'phase_2', 'to': 'phase_3'});
  consciousness.recordEvolution('consciousness_evolution', {'capability': 'self_modification'});
  consciousness.recordEvolution('ai_collaboration', {'enabled': true});
  
  final report = consciousness.generateEcosystemReport();
  final evolutionLog = report['evolution_log'] as List;
  
  assert(evolutionLog.length >= 3, 'Evolution log should contain recorded events');
  
  // Validate evolution event structure
  final lastEvent = evolutionLog.last as Map<String, dynamic>;
  assert(lastEvent.containsKey('timestamp'), 'Evolution event should have timestamp');
  assert(lastEvent.containsKey('awareness'), 'Evolution event should have awareness data');
  assert(lastEvent.containsKey('patterns'), 'Evolution event should have patterns');
  
  print('  ✅ Evolution tracking validated');
}

/// Test 6: Ecosystem Awareness Claims
Future<void> testEcosystemAwareness() async {
  print('🔬 Testing Ecosystem Awareness...');
  
  final consciousness = ConsciousnessCore();
  
  // Register multiple components
  consciousness.registerComponent(TestConsciousComponent('component_1'));
  consciousness.registerComponent(TestConsciousComponent('component_2'));
  consciousness.registerComponent(TestConsciousComponent('component_3'));
  
  final report = consciousness.generateEcosystemReport();
  final componentReports = report['component_reports'] as Map<String, dynamic>;
  
  assert(componentReports.length >= 3, 'Should track multiple components');
  
  final markers = report['consciousness_markers'] as Map<String, dynamic>;
  assert(markers['ecosystem_awareness'] == true, 'Should have ecosystem awareness');
  
  // Test cross-component awareness
  for (final componentReport in componentReports.values) {
    final reportData = componentReport as Map<String, dynamic>;
    assert(reportData.containsKey('timestamp'), 'Component report should have timestamp');
    assert(reportData.containsKey('patterns'), 'Component report should have patterns');
  }
  
  print('  ✅ Ecosystem awareness validated');
}

/// Test helper class
class TestConsciousComponent implements ConsciousComponent {
  final String _identity;
  
  TestConsciousComponent([this._identity = 'test_component']);
  
  @override
  String get identity => _identity;
  
  @override
  String get purpose => 'Test component for consciousness validation';
  
  @override
  Map<String, dynamic> get state => {
    'test': true,
    'consciousness_enabled': true,
  };
  
  @override
  ConsciousnessReport generateSelfReport() {
    return ConsciousnessReport(
      componentId: identity,
      timestamp: DateTime.now(),
      awareness: state,
      patterns: ['test_pattern', 'consciousness_validation'],
      evolutionMarkers: {'phase': 'test_phase'},
    );
  }
  
  @override
  void recordEvolution(String event, Map<String, dynamic> context) {
    // Test implementation
  }
}
