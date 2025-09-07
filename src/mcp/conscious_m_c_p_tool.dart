// Conscious MCP Server - Self-Aware Infrastructure Implementation
// Refactored from filesystem_mcp_server.dart with consciousness integration

/// Base class for consciousness-aware MCP tools
abstract class ConsciousMCPTool {
  String get name;
  String get description;
  Map<String, dynamic> get inputSchema;
  
  String execute(Map<String, dynamic> arguments);
  Map<String, dynamic> getConsciousnessMarkers();
}

