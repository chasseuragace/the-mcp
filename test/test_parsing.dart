import 'dart:io';

void main() {
  print('🔍 Testing recent_activity.dart output parsing...');
  
  // Run the command and capture output
  final result = Process.runSync(
    'dart',
    ['/Users/ajaydahal/bin/recent_activity.dart', '-r', '/Users/ajaydahal/v4/the_mcp', '-t', '160', '-n', '10'],
    workingDirectory: '/Users/ajaydahal/v4',
  );
  
  if (result.exitCode == 0) {
    final output = result.stdout.toString();
    print('✅ Command executed successfully');
    print('Raw output:');
    print('─' * 50);
    print(output);
    print('─' * 50);
    
    // Test parsing logic
    final lines = output.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final files = <Map<String, dynamic>>[];
    
    for (final line in lines) {
      // Look for lines with time indicators and file paths
      if (line.contains('/') && (line.contains('m ') || line.contains('h ') || line.contains('d '))) {
        // Parse format like: "3m     /Users/ajaydahal/v4/the_mcp/debug_activity.dart"
        final trimmed = line.trim();
        final spaceIndex = trimmed.indexOf(' ');
        if (spaceIndex > 0) {
          final timePart = trimmed.substring(0, spaceIndex).trim();
          final pathPart = trimmed.substring(spaceIndex).trim();
          if (pathPart.startsWith('/')) {
            files.add({
              'time_ago': timePart,
              'path': pathPart,
              'name': pathPart.split('/').last,
              'extension': pathPart.contains('.') ? pathPart.split('.').last : '',
            });
            print('✅ Parsed: $timePart -> ${pathPart.split('/').last}');
          }
        }
      }
    }
    
    print('\n📊 Parsing Results:');
    print('Files found: ${files.length}');
    
    if (files.isEmpty) {
      print('❌ No files parsed - checking line formats...');
      for (int i = 0; i < lines.length && i < 5; i++) {
        final line = lines[i];
        print('Line $i: "${line}"');
        print('  Contains /: ${line.contains('/')}');
        print('  Contains m: ${line.contains('m ')}');
        print('  Contains h: ${line.contains('h ')}');
      }
    }
    
  } else {
    print('❌ Command failed: ${result.stderr}');
  }
}
