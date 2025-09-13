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
  
  // Create a single subscription to the process output
  final output = process.stdout
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .asBroadcastStream();
  
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
    final response = await output.first.timeout(Duration(seconds: 5));
    
    final responseData = json.decode(response) as Map<String, dynamic>;
    
    if (responseData['jsonrpc'] != '2.0') {
      throw AssertionError('Should use JSON-RPC 2.0');
    }
    if (responseData['id'] != 1) {
      throw AssertionError('Should echo request ID');
    }
    if (!responseData.containsKey('result')) {
      throw AssertionError('Should have result');
    }
    
    final result = responseData['result'] as Map<String, dynamic>;
    if (!result.containsKey('capabilities')) {
      throw AssertionError('Should declare capabilities');
    }
    if (!result.containsKey('serverInfo')) {
      throw AssertionError('Should provide server info');
    }
    
    // Test consciousness-specific capabilities
    final capabilities = result['capabilities'] as Map<String, dynamic>;
    if (!capabilities.containsKey('consciousness')) {
      throw AssertionError('Should declare consciousness capabilities');
    }
    
    print('  ✅ MCP protocol compliance validated');
  } catch (e, stackTrace) {
    print('  ❌ Test failed: $e');
    print('  Stack trace: $stackTrace');
    rethrow;
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
  
  // Create a single subscription to the process output
  final output = process.stdout
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .asBroadcastStream();
  
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
    await output.first.timeout(Duration(seconds: 5));
    
    // Test tools/list
    final toolsListMessage = {
      'jsonrpc': '2.0',
      'id': 2,
      'method': 'tools/list',
      'params': {},
    };
    
    process.stdin.writeln(json.encode(toolsListMessage));
    
    final response = await output.first.timeout(Duration(seconds: 5));
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
    
    final toolResponse = await output.first.timeout(Duration(seconds: 5));
    final toolResponseData = json.decode(toolResponse) as Map<String, dynamic>;
    
    if (!toolResponseData.containsKey('result')) {
      print('  ❌ Tool response missing result: $toolResponseData');
      throw AssertionError('Tool should return result');
    }
    
    final toolResult = toolResponseData['result'] as Map<String, dynamic>;
    if (!toolResult.containsKey('consciousness_markers')) {
      print('  ❌ Tool result missing consciousness_markers: $toolResult');
      throw AssertionError('Tool should return consciousness markers');
    }
    
    print('  ✅ Tool execution validated');
  } catch (e, stackTrace) {
    print('  ❌ Test failed: $e');
    print('  Stack trace: $stackTrace');
    rethrow;
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
  
  // Create a single subscription to the process output
  final output = process.stdout
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .asBroadcastStream();
  
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
    await output.first.timeout(Duration(seconds: 5));
    
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
    
    final response = await output.first.timeout(Duration(seconds: 5));
    final responseData = json.decode(response) as Map<String, dynamic>;
    
    if (!responseData.containsKey('error')) {
      throw AssertionError('Should return error for restricted path');
    }
    
    final error = responseData['error'] as Map<String, dynamic>;
    if (error['code'] != -32603) {
      throw AssertionError('Should return internal error code');
    }
    if (error['message'] is! String) {
      throw AssertionError('Should have error message');
    }
    
    print('  ✅ Security enforcement validated');
  } catch (e, stackTrace) {
    print('  ❌ Test failed: $e');
    print('  Stack trace: $stackTrace');
    rethrow;
  } finally {
    process.kill();
  }
}

/// Test Backward Compatibility
Future<void> testBackwardCompatibility() async {
  print('🔬 Testing Backward Compatibility...');
  
  try {
    // Test legacy files still work by checking help output
    final process = await Process.start(
      'dart',
      ['run', 'legacy/recent_activity.dart', '--help'],
      workingDirectory: Directory.current.path,
    );
    
    // Read stderr to verify help is displayed (legacy script outputs help to stderr)
    final output = await process.stderr.transform(utf8.decoder).join();
    if (!output.contains('Usage:') || !output.contains('recent_activity.dart')) {
      throw AssertionError('Legacy script should show usage help in stderr');
    }
    
    // Wait for process to complete
    final exitCode = await process.exitCode;
    if (exitCode != 2) {  // Help typically exits with 2
      throw AssertionError('Legacy script help should exit with code 2, got $exitCode');
    }
    
    print('  ✅ Backward compatibility validated');
  } catch (e, stackTrace) {
    print('  ❌ Test failed: $e');
    print('  Stack trace: $stackTrace');
    rethrow;
  }
}

/// Test Consciousness Integration
Future<void> testConsciousnessIntegration() async {
  print('🔬 Testing Consciousness Integration...');
  
  final process = await Process.start(
    'dart',
    ['run', 'src/main.dart', '--read-paths', Directory.current.path, '--write-paths', '/tmp'],
    workingDirectory: Directory.current.path,
  );
  
  // Create a single subscription to the process output
  final output = process.stdout
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .asBroadcastStream();
  
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
    await output.first.timeout(Duration(seconds: 5));
    
    // Get consciousness report
    final reportMessage = {
      'jsonrpc': '2.0',
      'id': 2,
      'method': 'tools/call',
      'params': {
        'name': 'consciousness_report',
        'arguments': {'detailed': true},
      },
    };
    
    process.stdin.writeln(json.encode(reportMessage));
    
    final response = await output.first.timeout(Duration(seconds: 5));
    final responseData = json.decode(response) as Map<String, dynamic>;
    
    if (!responseData.containsKey('result')) {
      throw AssertionError('Should return result');
    }
    
    final result = responseData['result'] as Map<String, dynamic>;
   
    if (!result.containsKey('consciousness_phase')) {
      print(responseData);
      throw AssertionError('Should include consciousness phase');
    }
    if (!result.containsKey('analysis_root')) {
      throw AssertionError('Should include analysis root');
    }
    if (!result.containsKey('time_window')) {
      throw AssertionError('Should include time window');
    }
    
    print('  ✅ Consciousness integration validated');
  } catch (e, stackTrace) {
    print('  ❌ Test failed: $e');
    print('  Stack trace: $stackTrace');
    rethrow;
  } finally {
    process.kill();
  }
}
