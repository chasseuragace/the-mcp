import 'dart:io';
import 'src/intelligence/activity_intelligence_config.dart';
import 'src/intelligence/activity_intelligence.dart';

void main() async {
  print('🔍 Testing ActivityIntelligence instantiation...');
  
  try {
    final config = ActivityIntelligenceConfig(
      root: '/Users/ajaydahal',
      hours: 72,
      fileCount: 25,
    );
    print('✅ Config created');
    
    print('Creating ActivityIntelligence instance...');
    final intelligence = ActivityIntelligence(config);
    print('✅ ActivityIntelligence created');
    
    print('Identity: ${intelligence.identity}');
    print('Purpose: ${intelligence.purpose}');
    
    print('Testing state access...');
    final state = intelligence.state;
    print('✅ State accessed: ${state.keys}');
    
    print('🔍 Now testing analyzeActivity method (this might hang)...');
    
    // Set a timeout to avoid infinite hang
    final timeout = Duration(seconds: 10);
    final future = intelligence.analyzeActivity();
    
    final result = await future.timeout(timeout, onTimeout: () {
      throw TimeoutException('Analysis timed out after ${timeout.inSeconds}s');
    });
    
    print('✅ Analysis completed!');
    print('Files: ${result.files.length}');
    print('Directories: ${result.directories.length}');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    if (e.toString().contains('TimeoutException')) {
      print('The analysis is hanging - likely an infinite loop or blocking operation');
    }
    print('Stack trace: $stackTrace');
  }
}
