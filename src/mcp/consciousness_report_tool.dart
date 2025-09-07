// Conscious MCP Server - Self-Aware Infrastructure Implementation
// Refactored from filesystem_mcp_server.dart with consciousness integration

import 'dart:convert';
import '../core/consciousness.dart';
import '../core/consciousness_core.dart';
import 'conscious_m_c_p_tool.dart';
import 'conscious_server.dart';

/// Consciousness Report Tool
class ConsciousnessReportTool extends ConsciousMCPTool {
  final ConsciousMCPServer server;
  
  ConsciousnessReportTool(this.server);
  
  @override
  String get name => 'consciousness_report';
  
  @override
  String get description => 'Generate comprehensive consciousness ecosystem report';
  
  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'detailed': {'type': 'boolean', 'description': 'Include detailed analysis', 'default': true},
    },
  };
  
  @override
  String execute(Map<String, dynamic> arguments) {
    final detailed = arguments['detailed'] as bool? ?? true;
    final consciousness = ConsciousnessCore();
    final report = consciousness.generateEcosystemReport();
    
    return json.encode({
      'report_type': 'consciousness_ecosystem',
      'detailed': detailed,
      'data': report,
      'generated_by': 'conscious_mcp_server',
    });
  }
  
  @override
  Map<String, dynamic> getConsciousnessMarkers() => {
    'self_reporting': true,
    'ecosystem_awareness': true,
    'meta_cognitive': true,
  };
}

