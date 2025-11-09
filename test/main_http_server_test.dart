// Test for Conscious HTTP Server
// Tests HTTP endpoints and tool execution

import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

void main() {
  late Process serverProcess;
  final baseUrl = 'http://localhost:8081';
  final testReadPath = Directory.current.path;
  
  setUpAll(() async {
    // Start the HTTP server in a separate process
    print('Starting HTTP server...');
    serverProcess = await Process.start(
      'dart',
      [
        'run',
        'src/main_http_server.dart',
        '--port',
        '8081',
        '--host',
        'localhost',
        '--read-paths',
        testReadPath,
        '--write-paths',
        '/tmp',
      ],
    );
    
    // Wait for server to start
    await Future.delayed(Duration(seconds: 3));
    print('Server started');
  });
  
  tearDownAll(() async {
    // Stop the server
    print('Stopping server...');
    serverProcess.kill();
    await serverProcess.exitCode;
    print('Server stopped');
  });
  
  group('HTTP Server Endpoints', () {
    test('GET /health returns healthy status', () async {
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse('$baseUrl/health'));
        final response = await request.close();
        
        expect(response.statusCode, equals(HttpStatus.ok));
        
        final body = await utf8.decoder.bind(response).join();
        final data = json.decode(body) as Map<String, dynamic>;
        
        expect(data['status'], equals('healthy'));
        expect(data['name'], equals('the-mcp-conscious-http'));
        expect(data['version'], equals('2.0.0-consciousness'));
        expect(data['consciousness_level'], equals('phase_3_emerging'));
        expect(data['timestamp'], isNotNull);
      } finally {
        client.close();
      }
    });
    
    test('GET /tools returns list of available tools', () async {
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse('$baseUrl/tools'));
        final response = await request.close();
        
        expect(response.statusCode, equals(HttpStatus.ok));
        
        final body = await utf8.decoder.bind(response).join();
        final data = json.decode(body) as Map<String, dynamic>;
        
        expect(data['tools'], isA<List>());
        expect(data['count'], greaterThan(0));
        
        final tools = data['tools'] as List;
        expect(tools.isNotEmpty, isTrue);
        
        // Check first tool structure
        final firstTool = tools.first as Map<String, dynamic>;
        expect(firstTool['name'], isNotNull);
        expect(firstTool['description'], isNotNull);
        expect(firstTool['inputSchema'], isNotNull);
        expect(firstTool['consciousness_markers'], isNotNull);
        
        print('Available tools: ${tools.map((t) => t['name']).join(', ')}');
      } finally {
        client.close();
      }
    });
    
    test('GET /consciousness returns consciousness report', () async {
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse('$baseUrl/consciousness'));
        final response = await request.close();
        
        expect(response.statusCode, equals(HttpStatus.ok));
        
        final body = await utf8.decoder.bind(response).join();
        final data = json.decode(body) as Map<String, dynamic>;
        
        expect(data['consciousness_report'], isNotNull);
        final report = data['consciousness_report'] as Map<String, dynamic>;
        
        expect(report['component_id'], equals('conscious_mcp_server'));
        expect(report['timestamp'], isNotNull);
        expect(report['awareness'], isNotNull);
        expect(report['patterns'], isA<List>());
        expect(report['evolution_markers'], isNotNull);
      } finally {
        client.close();
      }
    });
    
    test('GET /invalid-path returns 404', () async {
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse('$baseUrl/invalid-path'));
        final response = await request.close();
        
        expect(response.statusCode, equals(HttpStatus.notFound));
        
        final body = await utf8.decoder.bind(response).join();
        final data = json.decode(body) as Map<String, dynamic>;
        
        expect(data['error'], equals('Not Found'));
        expect(data['path'], equals('/invalid-path'));
      } finally {
        client.close();
      }
    });
  });
  
  group('Tool Execution', () {
    test('POST /tools/activity_intelligence/execute works', () async {
      final client = HttpClient();
      try {
        final request = await client.postUrl(
          Uri.parse('$baseUrl/tools/activity_intelligence/execute'),
        );
        request.headers.contentType = ContentType.json;
        
        final arguments = {
          'root': testReadPath,
          'hours': 24,
          'fileCount': 10,
        };
        
        request.write(json.encode(arguments));
        final response = await request.close();
        
        expect(response.statusCode, equals(HttpStatus.ok));
        
        final body = await utf8.decoder.bind(response).join();
        final data = json.decode(body) as Map<String, dynamic>;
        
        expect(data['tool'], equals('activity_intelligence'));
        expect(data['result'], isNotNull);
        expect(data['timestamp'], isNotNull);
        
        // Parse the result (it's a JSON string)
        final result = json.decode(data['result']) as Map<String, dynamic>;
        expect(result['analysis_type'], equals('activity_intelligence'));
        expect(result['root'], equals(testReadPath));
        
        print('Activity intelligence result: ${result['files_found']} files found');
      } finally {
        client.close();
      }
    });
    
    test('POST /tools/invalid_tool/execute returns error', () async {
      final client = HttpClient();
      try {
        final request = await client.postUrl(
          Uri.parse('$baseUrl/tools/invalid_tool/execute'),
        );
        request.headers.contentType = ContentType.json;
        request.write(json.encode({}));
        final response = await request.close();
        
        expect(response.statusCode, equals(HttpStatus.internalServerError));
        
        final body = await utf8.decoder.bind(response).join();
        final data = json.decode(body) as Map<String, dynamic>;
        
        expect(data['error'], equals('Internal Server Error'));
        expect(data['message'], contains('Tool not found'));
      } finally {
        client.close();
      }
    });
    
    test('POST /tools/activity_intelligence/execute with invalid JSON returns 400', () async {
      final client = HttpClient();
      try {
        final request = await client.postUrl(
          Uri.parse('$baseUrl/tools/activity_intelligence/execute'),
        );
        request.headers.contentType = ContentType.json;
        request.write('invalid json');
        final response = await request.close();
        
        expect(response.statusCode, equals(HttpStatus.badRequest));
        
        final body = await utf8.decoder.bind(response).join();
        final data = json.decode(body) as Map<String, dynamic>;
        
        expect(data['error'], equals('Bad Request'));
        expect(data['message'], contains('Invalid JSON'));
      } finally {
        client.close();
      }
    });
  });
  
  group('CORS Support', () {
    test('OPTIONS request returns CORS headers', () async {
      final client = HttpClient();
      try {
        final request = await client.openUrl('OPTIONS', Uri.parse('$baseUrl/health'));
        final response = await request.close();
        
        expect(response.statusCode, equals(HttpStatus.ok));
        expect(
          response.headers.value('access-control-allow-origin'),
          equals('*'),
        );
        expect(
          response.headers.value('access-control-allow-methods'),
          contains('GET'),
        );
      } finally {
        client.close();
      }
    });
  });
}
