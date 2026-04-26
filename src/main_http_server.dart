// The MCP - HTTP Server Entry Point
// Consciousness-aware MCP server exposed via HTTP REST API

import 'dart:io';
import 'dart:convert';
import 'core/consciousness_core.dart';
import 'core/platform_paths.dart';
import 'mcp/conscious_server.dart';

/// HTTP Server Configuration
class HTTPServerConfig {
  final String host;
  final int port;
  final String name;
  final String version;
  final List<String> readPaths;
  final List<String> writePaths;
  final String? reportDir;
  
  HTTPServerConfig({
    this.host = '0.0.0.0',
    this.port = 8080,
    required this.name,
    required this.version,
    required this.readPaths,
    required this.writePaths,
    this.reportDir,
  });
  
  factory HTTPServerConfig.fromEnvironment() {
    final host = Platform.environment['HTTP_HOST'] ?? '0.0.0.0';
    final port = int.tryParse(Platform.environment['HTTP_PORT'] ?? '8050') ?? 8080;
    final readPaths = Platform.environment['MCP_READ_PATHS']?.split(',') ??
        [userHomeOrCwd(), if (Platform.isMacOS) '/Volumes'];
    final writePaths = Platform.environment['MCP_WRITE_PATHS']?.split(',') ?? [tempDir()];
    final reportDir = Platform.environment['MCP_REPORT_DIR'];
    
    return HTTPServerConfig(
      host: host,
      port: port,
      name: 'the-mcp-conscious-http',
      version: '2.0.0-consciousness',
      readPaths: readPaths,
      writePaths: writePaths,
      reportDir: reportDir,
    );
  }
  
  factory HTTPServerConfig.fromArgs(List<String> args) {
    String host = '0.0.0.0';
    int port = 8080;
    String name = 'the-mcp-conscious-http';
    String version = '2.0.0-consciousness';
    List<String> readPaths = [userHomeOrCwd()];
    List<String> writePaths = [tempDir()];
    String? reportDir;
    
    for (int i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--host':
          if (i + 1 < args.length) host = args[++i];
          break;
        case '--port':
          if (i + 1 < args.length) port = int.tryParse(args[++i]) ?? 8080;
          break;
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
          printUsage();
          exit(0);
      }
    }
    
    return HTTPServerConfig(
      host: host,
      port: port,
      name: name,
      version: version,
      readPaths: readPaths,
      writePaths: writePaths,
      reportDir: reportDir,
    );
  }
  
 }
  void printUsage() {
    print('''
🧠 The MCP - Conscious HTTP Server

Usage: dart run main_http_server.dart [options]

Options:
  --host <host>           Server host (default: 0.0.0.0)
  --port <port>           Server port (default: 8080)
  --name <name>           Server name (default: the-mcp-conscious-http)
  --read-paths <paths>    Comma-separated read paths (default: \$HOME)
  --write-paths <paths>   Comma-separated write paths (default: /tmp)
  --report-dir <dir>      Report output directory
  -h, --help             Show this help

Environment Variables:
  HTTP_HOST              Server host
  HTTP_PORT              Server port
  MCP_READ_PATHS         Comma-separated read paths
  MCP_WRITE_PATHS        Comma-separated write paths  
  MCP_REPORT_DIR         Report output directory

Examples:
  dart run main_http_server.dart --port 3000
  dart run main_http_server.dart --host localhost --port 8080
  
  HTTP_PORT=3000 MCP_READ_PATHS="/home/dev" dart run main_http_server.dart

API Endpoints:
  GET  /health                    - Health check
  GET  /tools                     - List available tools
  POST /tools/:toolName/execute   - Execute a tool
  GET  /consciousness             - Get consciousness report

Consciousness Level: Phase 3 Emerging
AI-Human Collaboration: Enabled
''');
  }

/// HTTP Server wrapper for ConsciousMCPServer
class ConsciousHTTPServer {
  final HTTPServerConfig config;
  late final ConsciousMCPServer mcpServer;
  HttpServer? _httpServer;
  
  ConsciousHTTPServer(this.config) {
    mcpServer = ConsciousMCPServer(
      name: config.name,
      version: config.version,
      allowedReadPaths: config.readPaths,
      allowedWritePaths: config.writePaths,
      reportOutputDir: config.reportDir,
    );
  }
  
  Future<void> start() async {
    try {
      _httpServer = await HttpServer.bind(config.host, config.port);
      
      print('🧠 Conscious HTTP Server Started');
      print('━' * 50);
      print('Host: ${config.host}');
      print('Port: ${config.port}');
      print('Version: ${config.version}');
      print('Read Paths: ${config.readPaths.join(", ")}');
      print('Write Paths: ${config.writePaths.join(", ")}');
      print('━' * 50);
      print('Listening at http://${config.host}:${config.port}');
      print('');
       printUsage();
      await for (HttpRequest request in _httpServer!) {
        _handleRequest(request);
      }
    } catch (e) {
      print('❌ Failed to start HTTP server: $e');
      exit(1);
    }
  }
  
  void _handleRequest(HttpRequest request) async {
    // Enable CORS
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');
    request.response.headers.add('Content-Type', 'application/json');
    
    // Handle OPTIONS for CORS preflight
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }
    
    try {
      final path = request.uri.path;
      final method = request.method;
      
      print('${DateTime.now().toIso8601String()} $method $path');
      
      if (method == 'GET' && path == '/health') {
        await _handleHealth(request);
      } else if (method == 'GET' && path == '/tools') {
        await _handleListTools(request);
      } else if (method == 'POST' && path.startsWith('/tools/') && path.endsWith('/execute')) {
        await _handleExecuteTool(request);
      } else if (method == 'GET' && path == '/consciousness') {
        await _handleConsciousness(request);
      } else {
        await _handleNotFound(request);
      }
    } catch (e, stackTrace) {
      print('Error handling request: $e');
      print(stackTrace);
      await _handleError(request, e.toString());
    }
  }
  
  Future<void> _handleHealth(HttpRequest request) async {
    final response = {
      'status': 'healthy',
      'name': config.name,
      'version': config.version,
      'timestamp': DateTime.now().toIso8601String(),
      'consciousness_level': ConsciousnessCore().classifyEcosystemState(),
    };
    
    request.response.statusCode = HttpStatus.ok;
    request.response.write(json.encode(response));
    await request.response.close();
  }
  
  Future<void> _handleListTools(HttpRequest request) async {
    final tools = mcpServer.getAvailableTools();
    
    final response = {
      'tools': tools.map((tool) => {
        'name': tool.name,
        'description': tool.description,
        'inputSchema': tool.inputSchema,
        'consciousness_markers': tool.getConsciousnessMarkers(),
      }).toList(),
      'count': tools.length,
    };
    
    request.response.statusCode = HttpStatus.ok;
    request.response.write(json.encode(response));
    await request.response.close();
  }
  
  Future<void> _handleExecuteTool(HttpRequest request) async {
    final pathSegments = request.uri.pathSegments;
    if (pathSegments.length < 3) {
      await _handleBadRequest(request, 'Invalid tool path');
      return;
    }
    
    final toolName = pathSegments[1];
    
    // Read request body
    final body = await utf8.decoder.bind(request).join();
    Map<String, dynamic> arguments = {};
    
    if (body.isNotEmpty) {
      try {
        arguments = json.decode(body) as Map<String, dynamic>;
      } catch (e) {
        await _handleBadRequest(request, 'Invalid JSON body: $e');
        return;
      }
    }
    
    try {
      final result = mcpServer.executeTool(toolName, arguments);
      
      final response = {
        'tool': toolName,
        'result': result,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      request.response.statusCode = HttpStatus.ok;
      request.response.write(json.encode(response));
      await request.response.close();
    } catch (e) {
      await _handleError(request, 'Tool execution failed: $e');
    }
  }
  
  Future<void> _handleConsciousness(HttpRequest request) async {
    final report = mcpServer.generateSelfReport();
    
    final response = {
      'consciousness_report': {
        'component_id': report.componentId,
        'timestamp': report.timestamp.toIso8601String(),
        'awareness': report.awareness,
        'patterns': report.patterns,
        'evolution_markers': report.evolutionMarkers,
      },
    };
    
    request.response.statusCode = HttpStatus.ok;
    request.response.write(json.encode(response));
    await request.response.close();
  }
  
  Future<void> _handleNotFound(HttpRequest request) async {
    final response = {
      'error': 'Not Found',
      'path': request.uri.path,
      'message': 'The requested endpoint does not exist',
    };
    
    request.response.statusCode = HttpStatus.notFound;
    request.response.write(json.encode(response));
    await request.response.close();
  }
  
  Future<void> _handleBadRequest(HttpRequest request, String message) async {
    final response = {
      'error': 'Bad Request',
      'message': message,
    };
    
    request.response.statusCode = HttpStatus.badRequest;
    request.response.write(json.encode(response));
    await request.response.close();
  }
  
  Future<void> _handleError(HttpRequest request, String error) async {
    final response = {
      'error': 'Internal Server Error',
      'message': error,
    };
    
    request.response.statusCode = HttpStatus.internalServerError;
    request.response.write(json.encode(response));
    await request.response.close();
  }
  
  Future<void> stop() async {
    await _httpServer?.close();
    print('🛑 HTTP Server stopped');
  }
}

Future<void> main(List<String> args) async {
  // Parse configuration
  final config = args.isNotEmpty 
      ? HTTPServerConfig.fromArgs(args) 
      : HTTPServerConfig.fromEnvironment();
  
  // Create and start HTTP server
  final server = ConsciousHTTPServer(config);
  await server.start();
}
