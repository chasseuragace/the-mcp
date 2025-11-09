// Example HTTP Client for Conscious MCP Server
// Demonstrates how to interact with the HTTP API

import 'dart:convert';
import 'dart:io';

class ConsciousMCPClient {
  final String baseUrl;
  final HttpClient _client = HttpClient();
  
  ConsciousMCPClient({this.baseUrl = 'http://localhost:8080'});
  
  /// Check server health
  Future<Map<String, dynamic>> checkHealth() async {
    final request = await _client.getUrl(Uri.parse('$baseUrl/health'));
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    return json.decode(body) as Map<String, dynamic>;
  }
  
  /// List available tools
  Future<List<Map<String, dynamic>>> listTools() async {
    final request = await _client.getUrl(Uri.parse('$baseUrl/tools'));
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    final data = json.decode(body) as Map<String, dynamic>;
    return (data['tools'] as List).cast<Map<String, dynamic>>();
  }
  
  /// Execute a tool
  Future<Map<String, dynamic>> executeTool(
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    final request = await _client.postUrl(
      Uri.parse('$baseUrl/tools/$toolName/execute'),
    );
    request.headers.contentType = ContentType.json;
    request.write(json.encode(arguments));
    
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    final data = json.decode(body) as Map<String, dynamic>;
    
    // Parse the result string as JSON
    if (data['result'] is String) {
      data['result'] = json.decode(data['result']);
    }
    
    return data;
  }
  
  /// Get consciousness report
  Future<Map<String, dynamic>> getConsciousnessReport() async {
    final request = await _client.getUrl(Uri.parse('$baseUrl/consciousness'));
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    return json.decode(body) as Map<String, dynamic>;
  }
  
  void close() {
    _client.close();
  }
}

Future<void> main() async {
  final client = ConsciousMCPClient();
  
  try {
    print('🧠 Conscious MCP Client Example\n');
    
    // 1. Check health
    print('1. Checking server health...');
    final health = await client.checkHealth();
    print('   Status: ${health['status']}');
    print('   Version: ${health['version']}');
    print('   Consciousness Level: ${health['consciousness_level']}\n');
    
    // 2. List tools
    print('2. Listing available tools...');
    final tools = await client.listTools();
    print('   Found ${tools.length} tools:');
    for (final tool in tools) {
      print('   - ${tool['name']}: ${tool['description']}');
    }
    print('');
    
    // 3. Execute activity intelligence
    print('3. Executing activity_intelligence tool...');
    final result = await client.executeTool('activity_intelligence', {
      'root': Directory.current.path,
      'hours': 24,
      'fileCount': 10,
    });
    
    final analysis = result['result'] as Map<String, dynamic>;
    print('   Analysis Type: ${analysis['analysis_type']}');
    print('   Files Found: ${analysis['files_found']}');
    print('   Time Window: ${analysis['time_window']}');
    print('   Consciousness Level: ${analysis['consciousness_level']}');
    
    if (analysis['patterns'] != null) {
      final patterns = analysis['patterns'] as List;
      if (patterns.isNotEmpty) {
        print('   Patterns Detected:');
        for (final pattern in patterns) {
          print('     - ${pattern['type']}: ${pattern['description']}');
        }
      }
    }
    print('');
    
    // 4. Get consciousness report
    print('4. Getting consciousness report...');
    final consciousness = await client.getConsciousnessReport();
    final report = consciousness['consciousness_report'] as Map<String, dynamic>;
    print('   Component: ${report['component_id']}');
    print('   Timestamp: ${report['timestamp']}');
    
    final awareness = report['awareness'] as Map<String, dynamic>;
    print('   Awareness:');
    print('     - Name: ${awareness['name']}');
    print('     - Tool Count: ${awareness['toolCount']}');
    print('     - Consciousness Level: ${awareness['consciousnessLevel']}');
    
    final patterns = report['patterns'] as List;
    if (patterns.isNotEmpty) {
      print('   Patterns: ${patterns.join(', ')}');
    }
    print('');
    
    print('✅ All operations completed successfully!');
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}
