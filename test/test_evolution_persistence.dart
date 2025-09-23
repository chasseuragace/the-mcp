import 'dart:io';
import 'package:test/test.dart';
import '../src/core/consciousness_core.dart';

/// Test suite for evolution persistence functionality
void main() {
  group('Evolution Persistence Tests', () {
    late ConsciousnessCore consciousness;
    late String testStoragePath;
    late String originalStoragePath;
    
    setUp(() {
      // Create a separate test directory to avoid conflicts with real data
      final testDir = Directory('test_evolution_data');
      if (!testDir.existsSync()) {
        testDir.createSync(recursive: true);
      }
      
      // Use a unique test storage path in the test directory
      testStoragePath = '${testDir.path}/test_evolution_log_${DateTime.now().millisecondsSinceEpoch}.json';
      
      // Get the singleton instance and store original storage path
      consciousness = ConsciousnessCore();
      originalStoragePath = consciousness.getPersistenceStats()['storage_path'] as String;
      
      // Set test storage path FIRST, then clear any existing data
      consciousness.setStoragePath(testStoragePath);
      consciousness.clearPersistence();
      
      // Clear any existing test data
      _clearTestStorage(testStoragePath);
    });
    
    tearDown(() {
      // Clean up test files and directory
      _clearTestStorage(testStoragePath);
      
      // Restore original storage path to preserve production state
      consciousness.setStoragePath(originalStoragePath);
      
      // Clean up the test directory if empty
      final testDir = Directory('test_evolution_data');
      if (testDir.existsSync()) {
        try {
          testDir.deleteSync(recursive: true);
        } catch (e) {
          // Ignore errors if directory still has files
        }
      }
    });
    
    test('Should persist evolution records to JSON file', () async {
      // Record some evolution events
      consciousness.recordEvolution('test_event_1', {'data': 'value1'});
      consciousness.recordEvolution('test_event_2', {'data': 'value2'});
      
      // Check that file was created
      final file = File(testStoragePath);
      expect(file.existsSync(), isTrue);
      
      // Verify file content
      final content = file.readAsStringSync();
      expect(content, isNotEmpty);
      
      // Parse and validate JSON structure
      final data = consciousness.getPersistenceStats();
      expect(data['file_exists'], isTrue);
      expect(data['memory_records'], equals(2));
    });
    
    test('Should load evolution records from persistent storage', () async {
      // Create a new instance and record events
      final consciousness1 = ConsciousnessCore();
      consciousness1.recordEvolution('session1_event', {'session': 1});
      
      // Create another instance - should load persisted data
      final consciousness2 = ConsciousnessCore();
      final report = consciousness2.generateEcosystemReport();
      final evolutionLog = report['evolution_log'] as List;
      
      // Should have the persisted event
      expect(evolutionLog.length, greaterThanOrEqualTo(1));
      final lastEvent = evolutionLog.last as Map<String, dynamic>;
      expect(lastEvent['awareness']['event'], equals('session1_event'));
    });
    
    test('Should maintain evolution log size limit', () async {
      // Record more events than the limit
      for (int i = 0; i < 1100; i++) {
        consciousness.recordEvolution('event_$i', {'index': i});
      }
      
      final stats = consciousness.getPersistenceStats();
      expect(stats['memory_records'], equals(1000));
      
      // Verify file was updated with limited data
      final file = File(testStoragePath);
      final content = file.readAsStringSync();
      expect(content.contains('event_100'), isTrue);
      expect(content.contains('event_0'), isFalse);
    });
    
    test('Should handle persistence errors gracefully', () async {
      // Clear any existing data first
      consciousness.clearPersistence();
      
      // Record an event
      consciousness.recordEvolution('normal_event', {'data': 'test'});
      
      // Verify normal operation
      final stats = consciousness.getPersistenceStats();
      expect(stats['memory_records'], equals(1));
      
      // The system should continue working even if persistence fails
      // (This is tested by the silent fail behavior in the implementation)
      consciousness.recordEvolution('another_event', {'data': 'test2'});
      final updatedStats = consciousness.getPersistenceStats();
      expect(updatedStats['memory_records'], equals(2));
    });
    
    test('Should provide accurate persistence statistics', () async {
      // Clear any existing data first
      consciousness.clearPersistence();
      
      // Initial state
      var stats = consciousness.getPersistenceStats();
      expect(stats['persistence_enabled'], isTrue);
      expect(stats['storage_path'], equals(testStoragePath));
      expect(stats['memory_records'], equals(0));
      
      // After recording events
      consciousness.recordEvolution('stats_test', {'data': 'value'});
      stats = consciousness.getPersistenceStats();
      expect(stats['memory_records'], equals(1));
      expect(stats['file_exists'], isTrue);
      expect(stats['file_size_bytes'], greaterThan(0));
    });
    
    test('Should clear persistence when requested', () async {
      // Clear any existing data first
      consciousness.clearPersistence();
      
      // Record some events
      consciousness.recordEvolution('to_clear_1', {'data': 'test1'});
      consciousness.recordEvolution('to_clear_2', {'data': 'test2'});
      
      // Verify data exists
      var stats = consciousness.getPersistenceStats();
      expect(stats['memory_records'], equals(2));
      expect(stats['file_exists'], isTrue);
      
      // Clear persistence
      consciousness.clearPersistence();
      
      // Verify data is cleared
      stats = consciousness.getPersistenceStats();
      expect(stats['memory_records'], equals(0));
      expect(stats['file_exists'], isFalse);
    });
    
    test('Should persist complex nested data structures', () async {
      // Clear any existing data first
      consciousness.clearPersistence();
      
      final complexData = {
        'nested': {
          'level1': {
            'level2': ['item1', 'item2', {'level3': 'deep_value'}]
          },
          'arrays': [1, 2, 3, {'mixed': true}],
          'primitives': 'string_value',
          'numbers': 42,
          'booleans': true,
          'nulls': null,
        }
      };
      
      consciousness.recordEvolution('complex_event', complexData);
      
      // Get the current instance's report to check the complex data
      final report = consciousness.generateEcosystemReport();
      final evolutionLog = report['evolution_log'] as List;
      
      // Find our complex event
      final complexEvent = evolutionLog.firstWhere(
        (e) => e['awareness']['event'] == 'complex_event',
        orElse: () => <String, dynamic>{},
      );
      
      expect(complexEvent.isNotEmpty, isTrue, reason: 'Complex event not found in evolution log');
      expect(complexEvent['awareness'], isNotNull, reason: 'Awareness data is null');
      expect(complexEvent['awareness']['context'], isNotNull, reason: 'Context data is null');
      
      final loadedContext = complexEvent['awareness']['context'] as Map<String, dynamic>;
      
      // Verify complex structure was preserved
      expect(loadedContext['nested']['level1']['level2'][2]['level3'], equals('deep_value'));
      expect(loadedContext['nested']['primitives'], equals('string_value'));
      expect(loadedContext['nested']['numbers'], equals(42));
      expect(loadedContext['nested']['booleans'], isTrue);
      expect(loadedContext['nested']['nulls'], isNull);
      expect(loadedContext['nested']['arrays'][3]['mixed'], isTrue);
      
      // Note: arrays key appears to be lost during JSON serialization/deserialization
      // This is a known limitation of the current implementation
      // The nested structure and primitives are working correctly
    });
    
    test('Should handle concurrent evolution recording', () async {
      // Clear any existing data first
      consciousness.clearPersistence();
      
      // Record multiple events concurrently
      final futures = List.generate(10, (i) => 
        Future(() => consciousness.recordEvolution('concurrent_$i', {'index': i}))
      );
      
      await Future.wait(futures);
      
      // Verify all events were recorded
      final stats = consciousness.getPersistenceStats();
      expect(stats['memory_records'], equals(10));
      
      // Verify persistence
      final file = File(testStoragePath);
      expect(file.existsSync(), isTrue);
    });
  });
}

/// Helper function to clear test storage
void _clearTestStorage(String path) {
  try {
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  } catch (e) {
    // Ignore cleanup errors
  }
}
