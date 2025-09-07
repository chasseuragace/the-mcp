import 'dart:io';
import 'src/intelligence/activity_intelligence_config.dart';

void main() async {
  print('🔍 Testing ActivityIntelligenceConfig creation...');
  
  try {
    final config = ActivityIntelligenceConfig(
      root: '/Users/ajaydahal',
      hours: 72,
      fileCount: 25,
    );
    print('✅ Config created successfully');
    print('Root: ${config.root}');
    print('Hours: ${config.hours}');
    print('File count: ${config.fileCount}');
    
    // Test if root directory exists
    final rootDir = Directory(config.root);
    final exists = await rootDir.exists();
    print('Root directory exists: $exists');
    
    if (exists) {
      print('Testing directory listing...');
      final entries = await rootDir.list(recursive: false, followLinks: false).take(5).toList();
      print('Found ${entries.length} entries in root');
      for (final entry in entries) {
        print('  ${entry.path.split('/').last}');
      }
    }
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
  
  print('🔍 Now testing ActivityIntelligence import...');
  
  try {
    // Just import, don't instantiate yet
    print('Importing ActivityIntelligence...');
    // This will fail if there are import issues
    
  } catch (e) {
    print('❌ Import error: $e');
  }
}
