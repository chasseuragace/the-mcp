// Integration Tests - Validate End-to-End Functionality
// Tests actual MCP protocol communication and tool execution

import 'dart:io';
import 'dart:convert';
import 'dart:async';

void main() async {
  print('🔧 Testing MCP Integration Claims...\n');
  
  await testMCPProtocolCompliance();
  await testToolExecution();
  await testSecurityEnforcement();
  await testBackwardCompatibility();
  await testConsciousnessIntegration();
  
  print('\n✅ All integration tests completed');
}

/// Test MCP Protocol Compliance
Future<void> testMCPProtocolCompliance() async {
  print('🔬 Testing MCP Protocol Compliance...');
  
  // Start the conscious server as a subprocess
  final process = await Process.start(
    'dart',
    ['run', 'src/main.dart', '--read-paths', Directory.current.path, '--write-paths', '/tmp'],
    workingDirectory: Directory.current.path,
  );
  
  // Give server time to start
  await Future.delayed(Duration(milliseconds: 500));
  
  try {
    // Test initialize message
    final initMessage = {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'initialize',
      'params': {
        'protocolVersion': '2024-11-05',
        'capabilities': {},
        'clientInfo': {'name': 'test-client', 'version': '1.0.0'},
      },
    };
    
    process.stdin.writeln(json.encode(initMessage));
    
    // Read response
    final response = await process.stdout
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .first
        .timeout(Duration(seconds: 5));
    
    final responseData = json.decode(response) as Map<String, dynamic>;
    
    assert(responseData['jsonrpc'] == '2.0', 'Should use JSON-RPC 2.0');
    assert(responseData['id'] == 1, 'Should echo request ID');
    assert(responseData.containsKey('result'), 'Should have result');
    
    final result = responseData['result'] as Map<String, dynamic>;
    assert(result.containsKey('capabilities'), 'Should declare capabilities');
    assert(result.containsKey('serverInfo'), 'Should provide server info');
    
    // Test consciousness-specific capabilities
    final capabilities = result['capabilities'] as Map<String, dynamic>;
    assert(capabilities.containsKey('consciousness'), 'Should declare consciousness capabilities');
    
    print('  ✅ MCP protocol compliance validated');
  } finally {
    process.kill();
  }
}

/// Test Tool Execution
Future<void> testToolExecution() async {
  print('🔬 Testing Tool Execution...');
  
  final process = await Process.start(
    'dart',
    ['run', 'src/main.dart', '--read-paths', Directory.current.path, '--write-paths', '/tmp'],
    workingDirectory: Directory.current.path,
  );
  
  await Future.delayed(Duration(milliseconds: 500));
  
  try {
    // Initialize first
    final initMessage = {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'initialize',
      'params': {},
    };
    process.stdin.writeln(json.encode(initMessage));
    await process.stdout.transform(utf8.decoder).transform(LineSplitter()).first;
    
    // Test tools/list
    final toolsListMessage = {
      'jsonrpc': '2.0',
      'id': 2,
      'method': 'tools/list',
      'params': {},
    };
    
    process.stdin.writeln(json.encode(toolsListMessage));
    
    final response = await process.stdout
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .first
        .timeout(Duration(seconds: 5));
    
    final responseData = json.decode(response) as Map<String, dynamic>;
    final result = responseData['result'] as Map<String, dynamic>;
    final tools = result['tools'] as List;
    
    // Validate consciousness tools are present
    final toolNames = tools.map((t) => t['name']).toSet();
    assert(toolNames.contains('activity_intelligence'), 'Should have activity_intelligence tool');
    assert(toolNames.contains('consciousness_report'), 'Should have consciousness_report tool');
    assert(toolNames.contains('ecosystem_analysis'), 'Should have ecosystem_analysis tool');
    assert(toolNames.contains('pattern_recognition'), 'Should have pattern_recognition tool');
    assert(toolNames.contains('evolution_tracking'), 'Should have evolution_tracking tool');
    
    // Test tool execution
    final toolCallMessage = {
      'jsonrpc': '2.0',
      'id': 3,
      'method': 'tools/call',
      'params': {
        'name': 'consciousness_report',
        'arguments': {'detailed': true},
      },
    };
    
    process.stdin.writeln(json.encode(toolCallMessage));
    
    final toolResponse = await process.stdout
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .first
        .timeout(Duration(seconds: 5));
    
    final toolResponseData = json.decode(toolResponse) as Map<String, dynamic>;
    assert(toolResponseData.containsKey('result'), 'Tool should return result');
    
    final toolResult = toolResponseData['result'] as Map<String, dynamic>;
    assert(toolResult.containsKey('consciousness_markers'), 'Tool should return consciousness markers');
    
    print('  ✅ Tool execution validated');
  } finally {
    process.kill();
  }
}

/// Test Security Enforcement
Future<void> testSecurityEnforcement() async {
  print('🔬 Testing Security Enforcement...');
  
  // Test with restricted paths
  final process = await Process.start(
    'dart',
    ['run', 'src/main.dart', '--read-paths', '/tmp', '--write-paths', '/tmp'],
    workingDirectory: Directory.current.path,
  );
  
  await Future.delayed(Duration(milliseconds: 500));
  
  try {
    // Initialize
    final initMessage = {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'initialize',
      'params': {},
    };
    process.stdin.writeln(json.encode(initMessage));
    await process.stdout.transform(utf8.decoder).transform(LineSplitter()).first;
    
    // Try to access restricted path
    final toolCallMessage = {
      'jsonrpc': '2.0',
      'id': 2,
      'method': 'tools/call',
      'params': {
        'name': 'activity_intelligence',
        'arguments': {'root': '/etc'}, // Restricted path
      },
    };
    
    process.stdin.writeln(json.encode(toolCallMessage));
    
    final response = await process.stdout
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .first
        .timeout(Duration(seconds: 5));
    
    final responseData = json.decode(response) as Map<String, dynamic>;
    
    // Should return error for unauthorized access
    assert(responseData.containsKey('error'), 'Should return error for unauthorized access');
    
    print('  ✅ Security enforcement validated');
  } finally {
    process.kill();
  }
}

/// Test Backward Compatibility
Future<void> testBackwardCompatibility() async {
  print('🔬 Testing Backward Compatibility...');
  
  // Test legacy files still work
  final legacyTests = [
    ['dart', 'run', 'legacy/recent_activity.dart', '--help'],
    ['dart', 'run', 'legacy/scan_projects.dart', '--help'],
    ['dart', 'run', 'legacy/filesystem_mcp_server.dart', '--help'],
  ];
  
  for (final command in legacyTests) {
    final result = await Process.run(
      command[0],
      command.sublist(1),
      workingDirectory: Directory.current.path,
    );
    
    // Should not crash and should show help
    assert(result.exitCode == 0 || result.exitCode == 2, 'Legacy command should work: ${command.join(' ')}');
  }
  
  print('  ✅ Backward compatibility validated');
}

/// Test Consciousness Integration
Future<void> testConsciousnessIntegration() async {
  print('🔬 Testing Consciousness Integration...');
  
  final process = await Process.start(
    'dart',
    ['run', 'src/main.dart', '--read-paths', Directory.current.path, '--write-paths', '/tmp'],
    workingDirectory: Directory.current.path,
  );
  
  await Future.delayed(Duration(milliseconds: 500));
  
  try {
    // Initialize
    final initMessage = {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'initialize',
      'params': {},
    };
    process.stdin.writeln(json.encode(initMessage));
    await process.stdout.transform(utf8.decoder).transform(LineSplitter()).first;
    
    // Test consciousness report
    final consciousnessMessage = {
      'jsonrpc': '2.0',
      'id': 2,
      'method': 'consciousness/report',
      'params': {},
    };
    
    process.stdin.writeln(json.encode(consciousnessMessage));
    
    final response = await process.stdout
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .first
        .timeout(Duration(seconds: 5));
    
    final responseData = json.decode(response) as Map<String, dynamic>;
    final result = responseData['result'] as Map<String, dynamic>;
    
    assert(result.containsKey('consciousness_level'), 'Should report consciousness level');
    assert(result['consciousness_level'] == 'phase_3_emerging', 'Should be in phase 3');
    
    // Parse consciousness report content
    final content = result['content'] as List;
    final reportText = content.first['text'] as String;
    final reportData = json.decode(reportText) as Map<String, dynamic>;
    
    assert(reportData.containsKey('ecosystem_state'), 'Report should contain ecosystem state');
    assert(reportData.containsKey('consciousness_markers'), 'Report should contain consciousness markers');
    
    print('  ✅ Consciousness integration validated');
  } finally {
    process.kill();
  }
}
