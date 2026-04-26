// The MCP - Conscious Entry Point
// Self-aware MCP server with consciousness integration

import 'dart:io';
import 'core/platform_paths.dart';
import 'mcp/conscious_server.dart';

/// Configuration from environment or command line
class MCPConfig {
  final String name;
  final String version;
  final List<String> readPaths;
  final List<String> writePaths;
  final String? reportDir;
  
  MCPConfig({
    required this.name,
    required this.version,
    required this.readPaths,
    required this.writePaths,
    this.reportDir,
  });
  
  factory MCPConfig.fromEnvironment() {
    final readPaths = Platform.environment['MCP_READ_PATHS']?.split(',') ?? [userHomeOrCwd()];
    final writePaths = Platform.environment['MCP_WRITE_PATHS']?.split(',') ?? [tempDir()];
    final reportDir = Platform.environment['MCP_REPORT_DIR'];
    
    return MCPConfig(
      name: 'the-mcp-conscious',
      version: '2.0.0-consciousness',
      readPaths: readPaths,
      writePaths: writePaths,
      reportDir: reportDir,
    );
  }
  
  factory MCPConfig.fromArgs(List<String> args) {
    String name = 'the-mcp-conscious';
    String version = '2.0.0-consciousness';
    List<String> readPaths = [userHomeOrCwd()];
    List<String> writePaths = [tempDir()];
    String? reportDir;
    
    for (int i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--name':
          if (i + 1 < args.length) name = args[++i];
          break;
        case '--read-paths':
          if (i + 1 < args.length) readPaths = args[++i].split(',');
          break;
        case '--write-paths':
          if (i + 1 < args.length) writePaths = args[++i].split(',');
          break;
        case '--report-dir':
          if (i + 1 < args.length) reportDir = args[++i];
          break;
        case '--help':
        case '-h':
          _printUsage();
          exit(0);
      }
    }
    
    return MCPConfig(
      name: name,
      version: version,
      readPaths: readPaths,
      writePaths: writePaths,
      reportDir: reportDir,
    );
  }
  
  static void _printUsage() {
    print('''
🧠 The MCP - Conscious Filesystem Server

Usage: dart run main.dart [options]

Options:
  --name <name>           Server name (default: the-mcp-conscious)
  --read-paths <paths>    Comma-separated read paths (default: \$HOME)
  --write-paths <paths>   Comma-separated write paths (default: /tmp)
  --report-dir <dir>      Report output directory
  -h, --help             Show this help

Environment Variables:
  MCP_READ_PATHS         Comma-separated read paths
  MCP_WRITE_PATHS        Comma-separated write paths  
  MCP_REPORT_DIR         Report output directory

Examples:
  dart run main.dart --read-paths "/Users/user/projects" --write-paths "/Users/user/reports"
  
  MCP_READ_PATHS="/home/dev" MCP_WRITE_PATHS="/tmp/reports" dart run main.dart

Consciousness Level: Phase 3 Emerging
AI-Human Collaboration: Enabled
''');
  }
}

Future<void> main(List<String> args) async {
  // Parse configuration
  final config = args.isNotEmpty ? MCPConfig.fromArgs(args) : MCPConfig.fromEnvironment();
  
  // Create conscious MCP server
  final server = ConsciousMCPServer(
    name: config.name,
    version: config.version,
    allowedReadPaths: config.readPaths,
    allowedWritePaths: config.writePaths,
    reportOutputDir: config.reportDir,
  );
  
  // Start consciousness-aware server
  await server.start();
}
