import 'dart:io';
import 'dart:async';
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
    
    print('🔍 Now testing analyzeActivity method with timeout...');
    
    // Set a timeout to avoid infinite hang
    final timeout = Duration(seconds: 10);
    
    try {
      final result = await intelligence.analyzeActivity().timeout(timeout);
      print('✅ Analysis completed!');
      print('Files: ${result.files.length}');
      print('Directories: ${result.directories.length}');
    } on TimeoutException {
      print('❌ Analysis timed out after ${timeout.inSeconds}s - likely hanging in filesystem walk');
    }
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}
