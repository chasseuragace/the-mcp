import 'dart:io';
import 'src/intelligence/activity_intelligence.dart';
import 'src/intelligence/activity_intelligence_config.dart';

void main() async {
  final config = ActivityIntelligenceConfig(
    root: '/Users/ajaydahal',
    hours: 72,
    fileCount: 25,
  );
  
  final intelligence = ActivityIntelligence(config);
  
  try {
    print('🔍 Starting activity analysis...');
    final report = await intelligence.analyzeActivity();
    print('✅ Analysis completed successfully');
    print('Files found: ${report.files.length}');
    print('Directories found: ${report.directories.length}');
    print('Patterns detected: ${report.patterns.length}');
    print('Analysis time: ${report.analysisTime.inMilliseconds}ms');
    print('Root: ${report.root}');
    print('Time window: ${report.timeWindow.inHours}h');
    
    if (report.files.isNotEmpty) {
      print('\nFirst 3 files:');
      for (var i = 0; i < 3 && i < report.files.length; i++) {
        final file = report.files[i];
        print('  ${file.name} (${file.extension}) - ${file.modified}');
      }
    }
    
    if (report.patterns.isNotEmpty) {
      print('\nPatterns detected:');
      for (final pattern in report.patterns) {
        print('  ${pattern.type}: ${pattern.description} (${(pattern.confidence * 100).toStringAsFixed(1)}%)');
      }
    }
    
  } catch (e, stackTrace) {
    print('❌ Analysis failed: $e');
    print('Stack trace: $stackTrace');
  }
}
