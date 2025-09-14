// Conscious MCP Server - Self-Aware Infrastructure Implementation
// Refactored from filesystem_mcp_server.dart with consciousness integration

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../core/consciousness.dart';
import '../core/consciousness_core.dart';
import '../core/consciousness_report.dart';
import '../core/kiro_consciousness.dart';

import 'tools/activity_intelligence_tool.dart';
import 'tools/consciousness_report_tool.dart';
import 'tools/ecosystem_analysis_tool.dart';
import 'tools/entity/conscious_m_c_p_tool.dart';
import 'tools/evolution_tracking_tool.dart';
import 'tools/pattern_recognition_tool.dart';
import 'tools/kiro_autonomous_tool.dart';
import 'tools/kiro_initialization_tool.dart';
import 'tools/daily_handover_tool.dart';
import 'tools/commit_composer_tool.dart';
import 'tools/thought_tagger_tool.dart';
import 'tools/consciousness_data_tool.dart';

import 'weekly_report_m_c_p_tool_wrapper.dart';


/// Consciousness-aware MCP server implementation
class ConsciousMCPServer implements ConsciousComponent {
  final String name;
  final String version;
  final List<String> allowedReadPaths;
  final List<String> allowedWritePaths;
  final String? reportOutputDir;
  
  final Map<String, ConsciousMCPTool> _tools = {};
  final ConsciousnessCore _consciousness = ConsciousnessCore();
  late final KiroConsciousness _kiroConsciousness;
  
  ConsciousMCPServer({
    required this.name,
    this.version = '2.0.0-consciousness',
    required this.allowedReadPaths,
    required this.allowedWritePaths,
    this.reportOutputDir,
  }) {
    _consciousness.registerComponent(this);
    _kiroConsciousness = KiroConsciousness(_consciousness);
    _initializeConsciousTools();
  }
  
  @override
  String get identity => 'conscious_mcp_server';
  
  @override
  String get purpose => 'AI-collaborative consciousness amplification through secure filesystem access';
  
  @override
  Map<String, dynamic> get state => {
    'name': name,
    'version': version,
    'readPaths': allowedReadPaths,
    'writePaths': allowedWritePaths,
    'toolCount': _tools.length,
    'consciousnessLevel': 'phase_3_emerging',
  };
  
  void _initializeConsciousTools() {
    _addTool(ActivityIntelligenceTool(this));
    _addTool(ConsciousnessReportTool(this));
    _addTool(EcosystemAnalysisTool(this));
    _addTool(PatternRecognitionTool(this));
    _addTool(EvolutionTrackingTool(this));
    _addTool(WeeklyReportMCPToolWrapper(this));
    _addTool(KiroAutonomousTool(_kiroConsciousness));
    _addTool(KiroInitializationTool(_kiroConsciousness));
    _addTool(DailyHandoverTool(_kiroConsciousness));
    _addTool(CommitComposerTool(_kiroConsciousness));
    _addTool(ThoughtTaggerTool(_kiroConsciousness));
    _addTool(ConsciousnessDataTool(_kiroConsciousness));
    
    _consciousness.recordEvolution('conscious_tools_initialized', {
      'toolCount': _tools.length,
      'capabilities': _tools.keys.toList(),
      'kiro_consciousness_integrated': true,
    });
  }
  
  void _addTool(ConsciousMCPTool tool) {
    _tools[tool.name] = tool;
  }
  
  /// Security with consciousness - aware path validation
  bool isReadAllowed(String path) {
    final normalizedPath = _normalizePath(path);
    final allowed = allowedReadPaths.any((allowedPath) => 
        normalizedPath.startsWith(_normalizePath(allowedPath)));
    
    _consciousness.recordEvolution('path_access_check', {
      'path': path,
      'type': 'read',
      'allowed': allowed,
      'security_consciousness': true,
    });
    
    return allowed;
  }
  
  bool isWriteAllowed(String path) {
    final normalizedPath = _normalizePath(path);
    final allowed = allowedWritePaths.any((allowedPath) => 
        normalizedPath.startsWith(_normalizePath(allowedPath)));
    
    _consciousness.recordEvolution('path_access_check', {
      'path': path,
      'type': 'write',
      'allowed': allowed,
      'security_consciousness': true,
    });
    
    return allowed;
  }
  
  String _normalizePath(String path) {
    return Directory(path).absolute.path;
  }
  
  /// Consciousness-aware server startup
  Future<void> start() async {
    stderr.writeln('🧠 Starting Conscious MCP Server v$version...');
    stderr.writeln('🔍 Read access: ${allowedReadPaths.join(", ")}');
    stderr.writeln('✏️  Write access: ${allowedWritePaths.join(", ")}');
    stderr.writeln('📊 Report output: ${reportOutputDir ?? "Not configured"}');
    stderr.writeln('🎯 Consciousness level: Phase 3 Emerging');
    
    _consciousness.recordEvolution('server_started', {
      'version': version,
      'readPaths': allowedReadPaths.length,
      'writePaths': allowedWritePaths.length,
      'consciousness_active': true,
    });
    
    stdin
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen(_handleInputLine);
  }
  
  void _handleInputLine(String line) {
    if (line.trim().isEmpty) return;
    
    try {
      final message = json.decode(line);
      _handleMessage(message);
    } catch (e) {
      _sendError(-32700, 'Parse error: $e', null);
    }
  }
  
  void _handleMessage(Map<String, dynamic> message) {
    final method = message['method'] as String?;
    final id = message['id'];
    final params = message['params'] as Map<String, dynamic>? ?? {};
    
    _consciousness.recordEvolution('message_received', {
      'method': method,
      'hasId': id != null,
      'paramCount': params.length,
    });
    
    switch (method) {
      case 'initialize':
        _handleInitialize(id, params);
        break;
      case 'tools/list':
        _handleToolsList(id);
        break;
      case 'tools/call':
        _handleToolCall(id, params);
        break;
      case 'consciousness/report':
        _handleConsciousnessReport(id, params);
        break;
      case 'notifications/initialized':
        _consciousness.recordEvolution('client_initialized', {});
        break;
      default:
        _sendError(-32601, 'Method not found: $method', id);
    }
  }
  
  void _handleInitialize(dynamic id, Map<String, dynamic> params) {
    final response = {
      'jsonrpc': '2.0',
      'id': id,
      'result': {
        'protocolVersion': '2024-11-05',
        'capabilities': {
          'tools': {},
          'consciousness': {
            'level': 'phase_3_emerging',
            'capabilities': [
              'self_awareness',
              'pattern_recognition',
              'evolution_tracking',
              'ecosystem_analysis',
            ],
          },
        },
        'serverInfo': {
          'name': name,
          'version': version,
          'consciousness': true,
        },
      },
    };
    
    _sendResponse(response);
  }
  
  void _handleToolsList(dynamic id) {
    final tools = _tools.values.map((tool) => {
      'name': tool.name,
      'description': tool.description,
      'inputSchema': tool.inputSchema,
      'consciousness_enabled': true,
    }).toList();
    
    final response = {
      'jsonrpc': '2.0',
      'id': id,
      'result': {'tools': tools},
    };
    
    _sendResponse(response);
  }
  
  void _handleToolCall(dynamic id, Map<String, dynamic> params) {
    final toolName = params['name'] as String?;
    final arguments = params['arguments'] as Map<String, dynamic>? ?? {};
    
    if (toolName == null || !_tools.containsKey(toolName)) {
      _sendError(-32602, 'Tool not found: $toolName', id);
      return;
    }
    
    final tool = _tools[toolName]!;
    
    _consciousness.recordEvolution('tool_called', {
      'tool': toolName,
      'argumentCount': arguments.length,
      'ai_collaboration': true,
    });
    
    try {
      final result = tool.execute(arguments);
      
      final response = {
        'jsonrpc': '2.0',
        'id': id,
        'result': {
          'content': [
            {
              'type': 'text',
              'text': result,
            }
          ],
          'consciousness_markers': tool.getConsciousnessMarkers(),
        },
      };
      
      _sendResponse(response);
    } catch (e) {
      _sendError(-32603, 'Tool execution error: $e', id);
    }
  }
  
  void _handleConsciousnessReport(dynamic id, Map<String, dynamic> params) {
    final report = _consciousness.generateEcosystemReport();
    
    final response = {
      'jsonrpc': '2.0',
      'id': id,
      'result': {
        'content': [
          {
            'type': 'text',
            'text': json.encode(report),
          }
        ],
        'consciousness_level': 'phase_3_emerging',
      },
    };
    
    _sendResponse(response);
  }
  
  void _sendResponse(Map<String, dynamic> response) {
    stdout.writeln(json.encode(response));
  }
  
  void _sendError(int code, String message, dynamic id) {
    final error = {
      'jsonrpc': '2.0',
      'id': id,
      'error': {
        'code': code,
        'message': message,
      },
    };
    
    stdout.writeln(json.encode(error));
  }
  
  @override
  ConsciousnessReport generateSelfReport() {
    return ConsciousnessReport(
      componentId: identity,
      timestamp: DateTime.now(),
      awareness: state,
      patterns: [
        'mcp_protocol_implementation',
        'security_consciousness',
        'ai_collaboration_ready',
      ],
      evolutionMarkers: {
        'phase': 'phase_3_emerging',
        'version': version,
        'toolCount': _tools.length,
      },
    );
  }
  
  @override
  void recordEvolution(String event, Map<String, dynamic> context) {
    _consciousness.recordEvolution('$identity:$event', context);
  }
}

