// Test for WeeklyReportMCPToolWrapper
// Testing project detection and report generation

import 'dart:io';
import '../src/mcp/weekly_report_m_c_p_tool_wrapper.dart';

void main() {
  print('🧠 Testing WeeklyReportMCPToolWrapper');
  print('=' * 50);
  
  // Test 1: Basic functionality
  testBasicFunctionality();
  
  // Test 2: Project detection on known directories
  testProjectDetection();
  
  // Test 3: Debug project scanning
  debugProjectScanning();
  
  // Test 4: Test with different time windows
  testTimeWindows();
}

void testBasicFunctionality() {
  print('\n📋 Test 1: Basic Functionality');
  print('-' * 30);
  
  try {
    final wrapper = WeeklyReportMCPToolWrapper(null);
    
    print('✅ Tool name: ${wrapper.name}');
    print('✅ Tool description: ${wrapper.description}');
    print('✅ Input schema keys: ${wrapper.inputSchema['properties']?.keys.toList()}');
    print('✅ Consciousness markers: ${wrapper.getConsciousnessMarkers()}');
  } catch (e) {
    print('❌ Basic functionality test failed: $e');
  }
}

void testProjectDetection() {
  print('\n🔍 Test 2: Project Detection on Known Directories');
  print('-' * 50);
  
  final testPaths = [
    '/Users/ajaydahal/v7',  // Should detect Python projects
    '/Users/ajaydahal/v4/the_mcp',  // Should detect Dart project (might not match patterns)
    '/Users/ajaydahal/bin',  // Should detect documentation
  ];
  
  final wrapper = WeeklyReportMCPToolWrapper(null);
  
  for (final path in testPaths) {
    print('\n📂 Testing: $path');
    try {
      final result = wrapper.execute({
        'root': path,
        'hours': 2160,  // 3 months
        'fileCount': 20,
      });
      
      // Extract project counts from result
      final lines = result.split('\n');
      var projectCount = 0;
      var frameworkCount = 0;
      
      for (final line in lines) {
        if (line.contains('Active Projects:')) {
          final match = RegExp(r'(\d+) across (\d+) frameworks').firstMatch(line);
          if (match != null) {
            projectCount = int.parse(match.group(1)!);
            frameworkCount = int.parse(match.group(2)!);
          }
          break;
        }
      }
      
      print('   Projects found: $projectCount');
      print('   Frameworks: $frameworkCount');
      
      if (projectCount == 0) {
        print('   ⚠️  No projects detected - investigating...');
        _debugProjectDetection(path, wrapper);
      } else {
        print('   ✅ Projects detected successfully');
      }
      
    } catch (e) {
      print('   ❌ Error testing $path: $e');
    }
  }
}

void _debugProjectDetection(String path, WeeklyReportMCPToolWrapper wrapper) {
  print('   🔧 Debug: Checking directory contents...');
  
  try {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      print('   ❌ Directory does not exist');
      return;
    }
    
    final entities = dir.listSync(recursive: false, followLinks: false);
    final subdirs = entities.whereType<Directory>().take(10).toList();
    
    print('   📁 Found ${subdirs.length} subdirectories:');
    for (final subdir in subdirs) {
      final name = subdir.path.split(Platform.pathSeparator).last;
      print('      - $name');
      
      // Check for project markers
      final markers = _checkProjectMarkers(subdir);
      if (markers.isNotEmpty) {
        print('        🎯 Project markers: ${markers.join(', ')}');
      }
    }
    
  } catch (e) {
    print('   ❌ Debug failed: $e');
  }
}

List<String> _checkProjectMarkers(Directory dir) {
  final markers = <String>[];
  final path = dir.path;
  final sep = Platform.pathSeparator;
  
  try {
    // Flutter markers
    if (File('$path${sep}pubspec.yaml').existsSync()) markers.add('pubspec.yaml');
    if (Directory('$path${sep}lib').existsSync()) markers.add('lib/');
    
    // JavaScript markers
    if (File('$path${sep}package.json').existsSync()) markers.add('package.json');
    if (File('$path${sep}nest-cli.json').existsSync()) markers.add('nest-cli.json');
    
    // Python markers
    if (File('$path${sep}requirements.txt').existsSync()) markers.add('requirements.txt');
    if (File('$path${sep}pyproject.toml').existsSync()) markers.add('pyproject.toml');
    if (File('$path${sep}setup.py').existsSync()) markers.add('setup.py');
    
    // Source directories
    if (Directory('$path${sep}src').existsSync()) markers.add('src/');
    if (Directory('$path${sep}lib').existsSync()) markers.add('lib/');
  } catch (e) {
    // Ignore access errors
  }
  
  return markers;
}

void debugProjectScanning() {
  print('\n🔧 Test 3: Debug Project Scanning Logic');
  print('-' * 40);
  
  final wrapper = WeeklyReportMCPToolWrapper(null);
  
  // Test the internal scanning method directly
  final testPath = '/Users/ajaydahal/v7';
  final threshold = DateTime.now().subtract(Duration(hours: 2160)); // 3 months
  
  print('📂 Scanning: $testPath');
  print('⏰ Threshold: $threshold');
  
  try {
    // Access the private method through reflection or create a test version
    final projects = _testScanProjectsSync(testPath, threshold, 50);
    
    print('\n📊 Scan Results:');
    for (final entry in projects.entries) {
      final type = entry.key;
      final projectList = entry.value;
      print('   $type: ${projectList.length} projects');
      
      for (final project in projectList.take(3)) {
        final age = DateTime.now().difference(project['lastModified'] as DateTime);
        print('      - ${project['name']} (${_formatAge(age)} ago)');
      }
    }
    
  } catch (e) {
    print('❌ Debug scanning failed: $e');
  }
}

// Duplicate the scanning logic for testing
Map<String, List<Map<String, dynamic>>> _testScanProjectsSync(String rootPath, DateTime threshold, int fileCount) {
  final projects = <String, List<Map<String, dynamic>>>{
    'Flutter': <Map<String, dynamic>>[],
    'NestJS': <Map<String, dynamic>>[],
    'React': <Map<String, dynamic>>[],
    'Node.js': <Map<String, dynamic>>[],
    'Python': <Map<String, dynamic>>[],
  };
  
  try {
    final rootDir = Directory(rootPath);
    _testWalkForProjects(rootDir, 0, threshold, projects);
    
    // Sort by most recent activity
    for (final list in projects.values) {
      list.sort((a, b) => (b['lastModified'] as DateTime).compareTo(a['lastModified'] as DateTime));
    }
  } catch (e) {
    print('   ❌ Scan error: $e');
  }
  
  return projects;
}

void _testWalkForProjects(Directory dir, int depth, DateTime threshold, Map<String, List<Map<String, dynamic>>> projects) {
  if (depth > 4) return;
  
  try {
    final entities = dir.listSync(recursive: false, followLinks: false);
    
    for (final entity in entities) {
      if (entity is Directory) {
        final name = entity.path.split(Platform.pathSeparator).last;
        if (_testShouldSkipDirectory(name)) continue;
        
        print('   🔍 Checking directory: $name');
        
        // Check for project types
        final projectType = _testDetectProjectTypeSync(entity);
        if (projectType != null) {
          print('      🎯 Detected project type: $projectType');
          final lastModified = _testGetLastModifiedSync(entity, projectType);
          print('      ⏰ Last modified: $lastModified');
          print('      📅 Threshold: $threshold');
          
          if (lastModified != null) {
            final isRecent = !lastModified.isBefore(threshold);
            print('      ✅ Recent activity: $isRecent');
            
            if (isRecent) {
              projects[projectType]!.add({
                'name': name,
                'path': entity.path,
                'lastModified': lastModified,
              });
              print('      ➕ Added to $projectType projects');
            }
          }
        } else if (depth < 3) {
          _testWalkForProjects(entity, depth + 1, threshold, projects);
        }
      }
    }
  } catch (e) {
    print('   ❌ Walk error: $e');
  }
}

String? _testDetectProjectTypeSync(Directory dir) {
  try {
    final path = dir.path;
    final sep = Platform.pathSeparator;
    
    print('        🔍 Detecting project type for: $path');
    
    // Flutter: pubspec.yaml + lib
    final pubspec = File('$path${sep}pubspec.yaml');
    final libDir = Directory('$path${sep}lib');
    if (pubspec.existsSync() && libDir.existsSync()) {
      print('        ✅ Flutter project detected (pubspec.yaml + lib/)');
      return 'Flutter';
    }
    
    // JavaScript projects
    final packageJson = File('$path${sep}package.json');
    if (packageJson.existsSync()) {
      print('        ✅ JavaScript project detected (package.json)');
      try {
        final content = packageJson.readAsStringSync();
        if (content.contains('"@nestjs/') || File('$path${sep}nest-cli.json').existsSync()) {
          print('        ✅ NestJS project detected');
          return 'NestJS';
        }
        if (content.contains('"react"')) {
          print('        ✅ React project detected');
          return 'React';
        }
        print('        ✅ Node.js project detected');
        return 'Node.js';
      } catch (e) {
        print('        ⚠️  Error reading package.json, defaulting to Node.js');
        return 'Node.js';
      }
    }
    
    // Python
    final requirements = File('$path${sep}requirements.txt');
    final pyproject = File('$path${sep}pyproject.toml');
    final setup = File('$path${sep}setup.py');
    
    if (requirements.existsSync() || pyproject.existsSync() || setup.existsSync()) {
      print('        ✅ Python project detected');
      return 'Python';
    }
    
    print('        ❌ No project type detected');
  } catch (e) {
    print('        ❌ Detection error: $e');
  }
  return null;
}

DateTime? _testGetLastModifiedSync(Directory projectDir, String projectType) {
  try {
    final codeDirs = <String>[];
    final extensions = <String>[];
    
    switch (projectType) {
      case 'Flutter':
        codeDirs.addAll(['lib', 'src']);
        extensions.add('dart');
        break;
      case 'NestJS':
        codeDirs.add('src');
        extensions.addAll(['ts', 'js']);
        break;
      case 'React':
        codeDirs.add('src');
        extensions.addAll(['js', 'ts', 'tsx', 'jsx']);
        break;
      case 'Node.js':
        codeDirs.add('src');
        extensions.addAll(['js', 'ts']);
        break;
      case 'Python':
        codeDirs.addAll(['src', '.']);
        extensions.add('py');
        break;
    }
    
    DateTime? latest;
    var fileCount = 0;
    
    for (final codeDir in codeDirs) {
      final dir = Directory('${projectDir.path}${Platform.pathSeparator}$codeDir');
      if (!dir.existsSync()) {
        print('          ❌ Code directory not found: $codeDir');
        continue;
      }
      
      print('          📁 Scanning code directory: $codeDir');
      
      try {
        final files = dir.listSync(recursive: true, followLinks: false);
        for (final file in files) {
          if (file is File) {
            final ext = file.path.split('.').last.toLowerCase();
            if (extensions.contains(ext)) {
              fileCount++;
              final stat = file.statSync();
              if (latest == null || stat.modified.isAfter(latest)) {
                latest = stat.modified;
              }
            }
          }
        }
      } catch (e) {
        print('          ❌ Error scanning $codeDir: $e');
      }
    }
    
    print('          📊 Found $fileCount relevant files, latest: $latest');
    return latest;
  } catch (e) {
    print('          ❌ Get last modified error: $e');
    return null;
  }
}

bool _testShouldSkipDirectory(String name) {
  const skipDirs = {
    '.git', '.idea', '.vscode', 'node_modules', '.dart_tool', 'build',
    '.pub-cache', '__pycache__', '.pytest_cache', 'venv', '.venv'
  };
  return skipDirs.contains(name) || name.startsWith('.');
}

String _formatAge(Duration duration) {
  if (duration.inDays > 0) return '${duration.inDays}d';
  if (duration.inHours > 0) return '${duration.inHours}h';
  return '${duration.inMinutes}m';
}

void testTimeWindows() {
  print('\n⏰ Test 4: Different Time Windows');
  print('-' * 35);
  
  final wrapper = WeeklyReportMCPToolWrapper(null);
  final testPath = '/Users/ajaydahal/v7';
  
  final timeWindows = [168, 720, 2160, 8760]; // 1 week, 1 month, 3 months, 1 year
  
  for (final hours in timeWindows) {
    print('\n🕐 Testing ${hours}h window (${(hours / 24).toStringAsFixed(1)} days):');
    
    try {
      final result = wrapper.execute({
        'root': testPath,
        'hours': hours,
        'fileCount': 10,
      });
      
      // Extract project count
      final lines = result.split('\n');
      for (final line in lines) {
        if (line.contains('Active Projects:')) {
          print('   $line');
          break;
        }
      }
      
    } catch (e) {
      print('   ❌ Error with ${hours}h window: $e');
    }
  }
}
