// Test comparing legacy vs new project detection logic

import 'dart:io';

void main() {
  print('🔍 Testing Legacy vs New Project Detection');
  print('=' * 50);
  
  final testPaths = [
    '/Users/ajaydahal/v7/v7.1',  // Should have Python files but no config
    '/Users/ajaydahal/v4/the_mcp',  // Dart project
  ];
  
  for (final path in testPaths) {
    print('\n📂 Testing: $path');
    testBothDetectionMethods(path);
  }
}

void testBothDetectionMethods(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    print('   ❌ Directory does not exist');
    return;
  }
  
  // Test legacy detection (strict config file based)
  final legacyResult = detectProjectTypeLegacy(dir);
  print('   🏛️  Legacy detection: ${legacyResult ?? "None"}');
  
  // Test new detection (flexible file based)
  final newResult = detectProjectTypeNew(dir);
  print('   🆕 New detection: ${newResult ?? "None"}');
  
  // Show what files exist
  print('   📁 Directory contents:');
  try {
    final entities = dir.listSync(recursive: false, followLinks: false);
    final files = entities.whereType<File>().take(10);
    final dirs = entities.whereType<Directory>().take(5);
    
    for (final file in files) {
      final name = file.path.split(Platform.pathSeparator).last;
      print('      📄 $name');
    }
    
    for (final subdir in dirs) {
      final name = subdir.path.split(Platform.pathSeparator).last;
      if (!name.startsWith('.')) {
        print('      📁 $name/');
        
        // Check if src/ has code files
        if (name == 'src') {
          final srcFiles = subdir.listSync(recursive: false, followLinks: false)
              .whereType<File>()
              .take(5);
          for (final srcFile in srcFiles) {
            final srcName = srcFile.path.split(Platform.pathSeparator).last;
            print('         📄 $srcName');
          }
        }
      }
    }
  } catch (e) {
    print('      ❌ Error listing contents: $e');
  }
}

// Legacy detection logic (from WeeklyReportTool)
String? detectProjectTypeLegacy(Directory dir) {
  try {
    final path = dir.path;
    final sep = Platform.pathSeparator;

    // Flutter: pubspec.yaml + (lib|src)
    final pubspec = File('$path${sep}pubspec.yaml');
    if (pubspec.existsSync()) {
      if (Directory('$path${sep}lib').existsSync() ||
          Directory('$path${sep}src').existsSync()) {
        return 'Flutter';
      }
    }

    // JavaScript projects
    final packageJson = File('$path${sep}package.json');
    if (packageJson.existsSync()) {
      try {
        final content = packageJson.readAsStringSync();
        // NestJS: @nestjs/* deps or nest-cli.json
        if (content.contains('"@nestjs/') ||
            File('$path${sep}nest-cli.json').existsSync()) {
          return 'NestJS';
        }
        // React: react dependency
        if (content.contains('"react"') || content.contains('"react-dom"')) {
          return 'React';
        }
      } catch (_) {}
      // Node.js (fallback)
      return 'Node.js';
    }

    // Python: pyproject.toml or requirements.txt or setup.py
    if (File('$path${sep}pyproject.toml').existsSync() ||
        File('$path${sep}requirements.txt').existsSync() ||
        File('$path${sep}setup.py').existsSync()) {
      return 'Python';
    }
  } catch (_) {}
  return null;
}

// New flexible detection logic
String? detectProjectTypeNew(Directory dir) {
  try {
    final path = dir.path;
    final sep = Platform.pathSeparator;
    
    // Flutter: pubspec.yaml + lib
    if (File('$path${sep}pubspec.yaml').existsSync() && Directory('$path${sep}lib').existsSync()) {
      return 'Flutter';
    }
    
    // JavaScript projects
    final packageJson = File('$path${sep}package.json');
    if (packageJson.existsSync()) {
      try {
        final content = packageJson.readAsStringSync();
        if (content.contains('"@nestjs/') || File('$path${sep}nest-cli.json').existsSync()) {
          return 'NestJS';
        }
        if (content.contains('"react"')) {
          return 'React';
        }
        return 'Node.js';
      } catch (e) {
        return 'Node.js';
      }
    }
    
    // Python - More flexible detection
    if (File('$path${sep}requirements.txt').existsSync() || 
        File('$path${sep}pyproject.toml').existsSync() ||
        File('$path${sep}setup.py').existsSync()) {
      return 'Python';
    }
    
    // Flexible Python detection - check for Python files in src structure
    final srcDir = Directory('$path${sep}src');
    if (srcDir.existsSync()) {
      if (hasPythonFiles(srcDir)) {
        return 'Python';
      }
      if (hasJavaScriptFiles(srcDir)) {
        return 'Node.js';
      }
      if (hasDartFiles(srcDir)) {
        return 'Flutter';
      }
    }
    
    // Check root directory for code files
    if (hasPythonFiles(dir)) {
      return 'Python';
    }
    
  } catch (e) {}
  return null;
}

bool hasPythonFiles(Directory dir) {
  try {
    final files = dir.listSync(recursive: false, followLinks: false);
    return files.any((entity) => 
      entity is File && entity.path.endsWith('.py'));
  } catch (e) {
    return false;
  }
}

bool hasJavaScriptFiles(Directory dir) {
  try {
    final files = dir.listSync(recursive: false, followLinks: false);
    return files.any((entity) => 
      entity is File && (entity.path.endsWith('.js') || 
                        entity.path.endsWith('.ts') ||
                        entity.path.endsWith('.tsx') ||
                        entity.path.endsWith('.jsx')));
  } catch (e) {
    return false;
  }
}

bool hasDartFiles(Directory dir) {
  try {
    final files = dir.listSync(recursive: false, followLinks: false);
    return files.any((entity) => 
      entity is File && entity.path.endsWith('.dart'));
  } catch (e) {
    return false;
  }
}
