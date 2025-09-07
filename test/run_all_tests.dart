// Test Runner - Execute All Test Suites
// Validates all claims made in documentation

import 'dart:io';

void main() async {
  print('🧪 The MCP - Comprehensive Test Suite');
  print('=====================================\n');
  
  final tests = [
    'consciousness_test.dart',
    'integration_test.dart', 
    'performance_test.dart',
  ];
  
  int passed = 0;
  int failed = 0;
  
  for (final test in tests) {
    print('Running $test...');
    
    final result = await Process.run(
      'dart',
      ['run', 'test/$test'],
      workingDirectory: Directory.current.path,
    );
    
    if (result.exitCode == 0) {
      print('✅ $test PASSED\n');
      passed++;
    } else {
      print('❌ $test FAILED');
      print('STDOUT: ${result.stdout}');
      print('STDERR: ${result.stderr}\n');
      failed++;
    }
  }
  
  print('=====================================');
  print('Test Results: $passed passed, $failed failed');
  
  if (failed == 0) {
    print('🎉 All consciousness claims validated!');
    exit(0);
  } else {
    print('💥 Some claims could not be validated');
    exit(1);
  }
}
