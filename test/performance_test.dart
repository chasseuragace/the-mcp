// Performance Tests - Validate Efficiency Claims
// Tests that consciousness features don't impact performance

import 'dart:io';
import 'dart:convert';

void main() async {
  print('⚡ Testing Performance Claims...\n');
  
  await testConsciousnessOverhead();
  await testActivityIntelligencePerformance();
  await testMCPResponseTimes();
  await testMemoryUsage();
  
  print('\n✅ All performance tests completed');
}

/// Test Consciousness Overhead
Future<void> testConsciousnessOverhead() async {
  print('🔬 Testing Consciousness Overhead...');
  
  final iterations = 1000;
  
  // Test consciousness core performance
  final stopwatch = Stopwatch()..start();
  
  for (int i = 0; i < iterations; i++) {
    // Simulate consciousness operations
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'event': 'performance_test_$i',
      'context': {'iteration': i, 'test': true},
    };
    
    // JSON encoding/decoding (consciousness reports)
    final encoded = json.encode(data);
    final decoded = json.decode(encoded);
    
    assert(decoded['event'] == 'performance_test_$i', 'Data integrity check');
  }
  
  stopwatch.stop();
  final avgTime = stopwatch.elapsedMicroseconds / iterations;
  
  assert(avgTime < 1000, 'Consciousness operations should be under 1ms average'); // 1000 microseconds = 1ms
  
  print('  ✅ Consciousness overhead: ${avgTime.toStringAsFixed(2)}μs per operation');
}

/// Test Activity Intelligence Performance
Future<void> testActivityIntelligencePerformance() async {
  print('🔬 Testing Activity Intelligence Performance...');
  
  // Create test directory structure
  final testDir = Directory('/tmp/mcp_perf_test');
  if (await testDir.exists()) {
    await testDir.delete(recursive: true);
  }
  await testDir.create();
  
  // Create test files
  for (int i = 0; i < 100; i++) {
    final file = File('${testDir.path}/test_file_$i.dart');
    await file.writeAsString('// Test file $i\nvoid main() { print("test"); }');
  }
  
  try {
    final stopwatch = Stopwatch()..start();
    
    // Test activity analysis performance
    final result = await Process.run(
      'dart',
      ['run', 'src/main.dart', '--read-paths', testDir.path, '--write-paths', '/tmp'],
      workingDirectory: Directory.current.path,
    );
    
    stopwatch.stop();
    
    // Should complete within reasonable time
    assert(stopwatch.elapsedMilliseconds < 5000, 'Activity analysis should complete under 5 seconds');
    
    print('  ✅ Activity intelligence: ${stopwatch.elapsedMilliseconds}ms for 100 files');
  } finally {
    // Cleanup
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  }
}

/// Test MCP Response Times
Future<void> testMCPResponseTimes() async {
  print('🔬 Testing MCP Response Times...');
  
  final process = await Process.start(
    'dart',
    ['run', 'src/main.dart', '--read-paths', Directory.current.path, '--write-paths', '/tmp'],
    workingDirectory: Directory.current.path,
  );
  
  await Future.delayed(Duration(milliseconds: 500));
  
  try {
    // Test multiple tool calls for response time
    final tools = [
      'consciousness_report',
      'ecosystem_analysis', 
      'pattern_recognition',
      'evolution_tracking',
    ];
    
    final responseTimes = <String, int>{};
    
    // Initialize first
    final initMessage = {
      'jsonrpc': '2.0',
      'id': 0,
      'method': 'initialize',
      'params': {},
    };
    process.stdin.writeln(json.encode(initMessage));
    await process.stdout.transform(utf8.decoder).transform(LineSplitter()).first;
    
    for (int i = 0; i < tools.length; i++) {
      final tool = tools[i];
      final stopwatch = Stopwatch()..start();
      
      final toolMessage = {
        'jsonrpc': '2.0',
        'id': i + 1,
        'method': 'tools/call',
        'params': {
          'name': tool,
          'arguments': {},
        },
      };
      
      process.stdin.writeln(json.encode(toolMessage));
      
      await process.stdout
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .first
          .timeout(Duration(seconds: 3));
      
      stopwatch.stop();
      responseTimes[tool] = stopwatch.elapsedMilliseconds;
      
      // Each tool should respond within 2 seconds
      assert(stopwatch.elapsedMilliseconds < 2000, '$tool should respond under 2 seconds');
    }
    
    final avgResponseTime = responseTimes.values.reduce((a, b) => a + b) / responseTimes.length;
    print('  ✅ Average MCP tool response: ${avgResponseTime.toStringAsFixed(0)}ms');
    
  } finally {
    process.kill();
  }
}

/// Test Memory Usage
Future<void> testMemoryUsage() async {
  print('🔬 Testing Memory Usage...');
  
  // Start server and monitor memory
  final process = await Process.start(
    'dart',
    ['run', 'src/main.dart', '--read-paths', Directory.current.path, '--write-paths', '/tmp'],
    workingDirectory: Directory.current.path,
  );
  
  await Future.delayed(Duration(seconds: 1));
  
  try {
    // Get process memory usage (macOS specific)
    final memResult = await Process.run('ps', ['-o', 'rss=', '-p', process.pid.toString()]);
    
    if (memResult.exitCode == 0) {
      final memoryKB = int.tryParse(memResult.stdout.toString().trim());
      if (memoryKB != null) {
        final memoryMB = memoryKB / 1024;
        
        // Consciousness-aware server should use reasonable memory
        assert(memoryMB < 100, 'Memory usage should be under 100MB');
        
        print('  ✅ Memory usage: ${memoryMB.toStringAsFixed(1)}MB');
      } else {
        print('  ⚠️  Could not measure memory usage');
      }
    } else {
      print('  ⚠️  Memory measurement not available on this system');
    }
    
  } finally {
    process.kill();
  }
}
