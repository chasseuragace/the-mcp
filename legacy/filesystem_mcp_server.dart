import 'dart:io';
import 'dart:convert';
import 'dart:async';

class FilesystemMCPServer {
  final String name;
  final String version;
  final Map<String, MCPTool> tools = {};
  
  // Configurable access paths
  final List<String> allowedReadPaths;
  final List<String> allowedWritePaths;
  final String? reportOutputDir;
  
  FilesystemMCPServer({
    required this.name,
    this.version = '1.0.0',
    required this.allowedReadPaths,
    required this.allowedWritePaths,
    this.reportOutputDir,
  }) {
    _initializeTools();
  }
  
  void _initializeTools() {
    addTool(FileAnalyzerTool(this));
    addTool(ReportGeneratorTool(this));
    addTool(DirectoryListTool(this));
    addTool(FileReaderTool(this));
    addTool(RecentActivityTool(this));
    addTool(ScanProjectsTool(this));
  }
  
  void addTool(MCPTool tool) {
    tools[tool.name] = tool;
  }
  
  // Security: Check if path is allowed for reading
  bool isReadAllowed(String path) {
    final normalizedPath = _normalizePath(path);
    return allowedReadPaths.any((allowedPath) => 
        normalizedPath.startsWith(_normalizePath(allowedPath)));
  }
  
  // Security: Check if path is allowed for writing
  bool isWriteAllowed(String path) {
    final normalizedPath = _normalizePath(path);
    return allowedWritePaths.any((allowedPath) => 
        normalizedPath.startsWith(_normalizePath(allowedPath)));
  }
  
  String _normalizePath(String path) {
    return Directory(path).absolute.path;
  }
  
  void start() {
    stderr.writeln('Starting Filesystem MCP Server...');
    stderr.writeln('Read access: ${allowedReadPaths.join(", ")}');
    stderr.writeln('Write access: ${allowedWritePaths.join(", ")}');
    stderr.writeln('Report output: ${reportOutputDir ?? "Not configured"}');
    
    stdin
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen((line) {
      if (line.trim().isEmpty) return;
      
      try {
        final message = json.decode(line);
        _handleMessage(message);
      } catch (e) {
        _sendError(-32700, 'Parse error', null);
      }
    });
  }
  
  void _handleMessage(Map<String, dynamic> message) {
    final method = message['method'] as String?;
    final id = message['id'];
    final params = message['params'] as Map<String, dynamic>? ?? {};
    
    switch (method) {
      case 'initialize':
        _handleInitialize(id, params);
        break;
      case 'tools/list':
        _handleToolsList(id);
        break;
      case 'tools/call':
        _handleToolCall(id, params);
        break;
      case 'notifications/initialized':
        break;
      default:
        _sendError(-32601, 'Method not found', id);
    }
  }
  
  void _handleInitialize(dynamic id, Map<String, dynamic> params) {
    final response = {
      'jsonrpc': '2.0',
      'id': id,
      'result': {
        'protocolVersion': '2024-11-05',
        'capabilities': {
          'tools': {},
        },
        'serverInfo': {
          'name': name,
          'version': version,
        }
      }
    };
    _sendResponse(response);
  }
  
  void _handleToolsList(dynamic id) {
    final toolList = tools.values.map((tool) => {
      'name': tool.name,
      'description': tool.description,
      'inputSchema': tool.inputSchema,
    }).toList();
    
    final response = {
      'jsonrpc': '2.0',
      'id': id,
      'result': {
        'tools': toolList,
      }
    };
    _sendResponse(response);
  }
  
  Future<void> _handleToolCall(dynamic id, Map<String, dynamic> params) async {
    final toolName = params['name'] as String?;
    final arguments = params['arguments'] as Map<String, dynamic>? ?? {};
    
    if (toolName == null || !tools.containsKey(toolName)) {
      _sendError(-32602, 'Tool not found', id);
      return;
    }
    
    try {
      final tool = tools[toolName]!;
      final result = await tool.execute(arguments);
      
      final response = {
        'jsonrpc': '2.0',
        'id': id,
        'result': {
          'content': [
            {
              'type': 'text',
              'text': result,
            }
          ]
        }
      };
      _sendResponse(response);
    } catch (e) {
      _sendError(-32603, 'Tool execution failed: $e', id);
    }
  }
  
  void _sendResponse(Map<String, dynamic> response) {
    stdout.writeln(json.encode(response));
  }
  
  void _sendError(int code, String message, dynamic id) {
    final error = {
      'jsonrpc': '2.0',
      'id': id,
      'error': {
        'code': code,
        'message': message,
      }
    };
    stdout.writeln(json.encode(error));
  }
}

class RecentActivityTool extends MCPTool {
  final FilesystemMCPServer server;

  RecentActivityTool(this.server);

  @override
  String get name => 'recent_activity';

  @override
  String get description => 'Scan recent file activity and new directories with filters';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'root': {'type': 'string', 'description': 'Root directory to scan'},
      'file_count': {'type': 'integer', 'description': 'Top N files to list'},
      'dir_count': {'type': 'integer', 'description': 'Top N directories to list'},
      'hours': {'type': 'integer', 'description': 'Time window in hours'},
      'verbose': {'type': 'boolean'},
      'summarize': {'type': 'boolean'},
      'quick': {'type': 'boolean'},
      'only_user_exts': {'type': 'boolean'},
      'extra_excludes': {
        'type': 'array',
        'items': {'type': 'string'},
        'description': 'Additional exclude patterns (names or paths)'
      },
      'include_exts': {
        'type': 'array',
        'items': {'type': 'string'},
        'description': 'File extensions to include (e.g., ["md","dart"])'
      },
    },
    'required': ['root']
  };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final root = arguments['root'] as String;
    if (!server.isReadAllowed(root)) {
      throw Exception('Access denied to directory: $root');
    }

    final scriptDir = File(Platform.script.toFilePath()).parent.path;
    final scriptPath = '$scriptDir${Platform.pathSeparator}recent_activity.dart';

    final args = <String>[];
    args.addAll(['-r', root]);
    if (arguments['file_count'] != null) {
      args.addAll(['-n', (arguments['file_count'] as int).toString()]);
    }
    if (arguments['dir_count'] != null) {
      args.addAll(['-d', (arguments['dir_count'] as int).toString()]);
    }
    if (arguments['hours'] != null) {
      args.addAll(['-t', (arguments['hours'] as int).toString()]);
    }
    if (arguments['verbose'] == true) args.add('-v');
    if (arguments['summarize'] == true) args.add('-s');
    if (arguments['quick'] == true) args.add('-q');
    if (arguments['only_user_exts'] == true) args.add('-O');
    final extraExcludes = (arguments['extra_excludes'] as List?)?.cast<String>() ?? const <String>[];
    for (final x in extraExcludes) {
      args.addAll(['-x', x]);
    }
    final includeExts = (arguments['include_exts'] as List?)?.cast<String>() ?? const <String>[];
    for (final e in includeExts) {
      args.addAll(['-e', e]);
    }

    final result = await Process.run('dart', [scriptPath, ...args]);
    if (result.exitCode != 0) {
      final err = (result.stderr is String) ? result.stderr as String : result.stderr.toString();
      throw Exception('recent_activity failed (code ${result.exitCode}):\n$err');
    }
    final out = (result.stdout is String) ? result.stdout as String : result.stdout.toString();
    return out.trim().isEmpty ? 'recent_activity completed with no output' : out;
  }
}

class ScanProjectsTool extends MCPTool {
  final FilesystemMCPServer server;

  ScanProjectsTool(this.server);

  @override
  String get name => 'scan_projects';

  @override
  String get description => 'Scan edited projects by type and generate windowed reports';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'root': {'type': 'string', 'description': 'Root directory to scan'},
      'hours': {'type': 'integer', 'description': 'Time window in hours'},
      'count': {'type': 'integer', 'description': 'Max projects per group'},
      'verbose': {'type': 'boolean'},
    },
    'required': ['root']
  };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final root = arguments['root'] as String;
    if (!server.isReadAllowed(root)) {
      throw Exception('Access denied to directory: $root');
    }

    final scriptDir = File(Platform.script.toFilePath()).parent.path;
    final scriptPath = '$scriptDir${Platform.pathSeparator}scan_projects.dart';

    // Determine output reports directory: prefer configured reportOutputDir, else first allowed write path
    final outDir = server.reportOutputDir ?? (server.allowedWritePaths.isNotEmpty ? server.allowedWritePaths.first : '');
    if (outDir.isEmpty) {
      throw Exception('No writable report directory configured');
    }
    if (!server.isWriteAllowed('$outDir${Platform.pathSeparator}dummy')) {
      throw Exception('Write not allowed for reports in: $outDir');
    }

    final args = <String>[];
    args.addAll(['-r', root]);
    if (arguments['hours'] != null) {
      args.addAll(['-t', (arguments['hours'] as int).toString()]);
    }
    if (arguments['count'] != null) {
      args.addAll(['-n', (arguments['count'] as int).toString()]);
    }
    if (arguments['verbose'] == true) args.add('-v');

    final result = await Process.run('dart', [scriptPath, ...args]);
    final stdoutStr = (result.stdout is String) ? result.stdout as String : result.stdout.toString();
    final stderrStr = (result.stderr is String) ? result.stderr as String : result.stderr.toString();
    if (result.exitCode != 0) {
      throw Exception('scan_projects failed (code ${result.exitCode}):\n$stderrStr');
    }
    // Return stdout and note that reports were saved in script directory
    return " $stdoutStr \nScan complete";
  }
}

abstract class MCPTool {
  String get name;
  String get description;
  Map<String, dynamic> get inputSchema;
  
  Future<String> execute(Map<String, dynamic> arguments);
}

class FileAnalyzerTool extends MCPTool {
  final FilesystemMCPServer server;
  
  FileAnalyzerTool(this.server);
  
  @override
  String get name => 'analyze_files';
  
  @override
  String get description => 'Analyzes files in a directory and generates statistics';
  
  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'directory': {
        'type': 'string',
        'description': 'Directory path to analyze'
      },
      'file_extensions': {
        'type': 'array',
        'items': {'type': 'string'},
        'description': 'File extensions to include (e.g., [".dart", ".json"])'
      }
    },
    'required': ['directory']
  };
  
  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final directory = arguments['directory'] as String;
    final extensions = (arguments['file_extensions'] as List?)?.cast<String>() ?? [];
    
    if (!server.isReadAllowed(directory)) {
      throw Exception('Access denied to directory: $directory');
    }
    
    final dir = Directory(directory);
    if (!await dir.exists()) {
      throw Exception('Directory not found: $directory');
    }
    
    int totalFiles = 0;
    int totalSize = 0;
    Map<String, int> extensionCounts = {};
    Map<String, int> extensionSizes = {};
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final fileName = entity.path.toLowerCase();
        
        // Filter by extensions if specified
        if (extensions.isNotEmpty && 
            !extensions.any((ext) => fileName.endsWith(ext.toLowerCase()))) {
          continue;
        }
        
        try {
          final stat = await entity.stat();
          final extension = fileName.split('.').last;
          
          totalFiles++;
          totalSize += stat.size;
          extensionCounts[extension] = (extensionCounts[extension] ?? 0) + 1;
          extensionSizes[extension] = (extensionSizes[extension] ?? 0) + stat.size;
        } catch (e) {
          // Skip files we can't access
        }
      }
    }
    
    final report = StringBuffer();
    report.writeln('File Analysis Report for: $directory');
    report.writeln('=' * 50);
    report.writeln('Total files: $totalFiles');
    report.writeln('Total size: ${_formatBytes(totalSize)}');
    report.writeln();
    report.writeln('By file extension:');
    
    final sortedExtensions = extensionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final entry in sortedExtensions) {
      final ext = entry.key;
      final count = entry.value;
      final size = extensionSizes[ext] ?? 0;
      report.writeln('  .$ext: $count files (${_formatBytes(size)})');
    }
    
    return report.toString();
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class ReportGeneratorTool extends MCPTool {
  final FilesystemMCPServer server;
  
  ReportGeneratorTool(this.server);
  
  @override
  String get name => 'generate_report';
  
  @override
  String get description => 'Generates and saves a detailed filesystem report';
  
  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'source_directory': {
        'type': 'string',
        'description': 'Directory to analyze'
      },
      'report_name': {
        'type': 'string',
        'description': 'Name for the report file (without extension)'
      },
      'format': {
        'type': 'string',
        'enum': ['txt', 'json', 'csv'],
        'description': 'Report format'
      }
    },
    'required': ['source_directory', 'report_name']
  };
  
  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final sourceDir = arguments['source_directory'] as String;
    final reportName = arguments['report_name'] as String;
    final format = (arguments['format'] as String?) ?? 'txt';
    
    if (!server.isReadAllowed(sourceDir)) {
      throw Exception('Access denied to source directory: $sourceDir');
    }
    
    // Determine output path
    final outputDir = server.reportOutputDir ?? server.allowedWritePaths.first;
    final outputPath = '$outputDir/${reportName}.${format}';
    
    if (!server.isWriteAllowed(outputPath)) {
      throw Exception('Access denied to write report: $outputPath');
    }
    
    // Generate report data
    final reportData = await _generateReportData(sourceDir);
    
    // Format and save report
    final reportContent = _formatReport(reportData, format);
    final outputFile = File(outputPath);
    await outputFile.writeAsString(reportContent);
    
    return 'Report generated successfully: $outputPath\nReport contains ${reportData['totalFiles']} files totaling ${reportData['totalSize']} bytes';
  }
  
  Future<Map<String, dynamic>> _generateReportData(String directory) async {
    final dir = Directory(directory);
    int totalFiles = 0;
    int totalSize = 0;
    List<Map<String, dynamic>> fileList = [];
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        try {
          final stat = await entity.stat();
          totalFiles++;
          totalSize += stat.size;
          
          fileList.add({
            'path': entity.path,
            'size': stat.size,
            'modified': stat.modified.toIso8601String(),
            'extension': entity.path.split('.').last,
          });
        } catch (e) {
          // Skip inaccessible files
        }
      }
    }
    
    return {
      'directory': directory,
      'totalFiles': totalFiles,
      'totalSize': totalSize,
      'files': fileList,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
  
  String _formatReport(Map<String, dynamic> data, String format) {
    switch (format) {
      case 'json':
        return json.encode(data);
      case 'csv':
        final buffer = StringBuffer();
        buffer.writeln('Path,Size,Modified,Extension');
        for (final file in data['files'] as List) {
          buffer.writeln('${file['path']},${file['size']},${file['modified']},${file['extension']}');
        }
        return buffer.toString();
      default: // txt
        final buffer = StringBuffer();
        buffer.writeln('Filesystem Report');
        buffer.writeln('Generated: ${data['generatedAt']}');
        buffer.writeln('Directory: ${data['directory']}');
        buffer.writeln('Total Files: ${data['totalFiles']}');
        buffer.writeln('Total Size: ${data['totalSize']} bytes');
        buffer.writeln();
        buffer.writeln('Files:');
        for (final file in data['files'] as List) {
          buffer.writeln('${file['path']} (${file['size']} bytes, ${file['modified']})');
        }
        return buffer.toString();
    }
  }
}

class DirectoryListTool extends MCPTool {
  final FilesystemMCPServer server;
  
  DirectoryListTool(this.server);
  
  @override
  String get name => 'list_directory';
  
  @override
  String get description => 'Lists contents of a directory';
  
  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'path': {
        'type': 'string',
        'description': 'Directory path to list'
      },
      'recursive': {
        'type': 'boolean',
        'description': 'Whether to list recursively'
      }
    },
    'required': ['path']
  };
  
  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final path = arguments['path'] as String;
    final recursive = (arguments['recursive'] as bool?) ?? false;
    
    if (!server.isReadAllowed(path)) {
      throw Exception('Access denied to directory: $path');
    }
    
    final dir = Directory(path);
    if (!await dir.exists()) {
      throw Exception('Directory not found: $path');
    }
    
    final buffer = StringBuffer();
    buffer.writeln('Directory listing: $path');
    buffer.writeln('-' * 40);
    
    await for (final entity in dir.list(recursive: recursive)) {
      final type = entity is Directory ? 'DIR' : 'FILE';
      buffer.writeln('[$type] ${entity.path}');
    }
    
    return buffer.toString();
  }
}

class FileReaderTool extends MCPTool {
  final FilesystemMCPServer server;
  
  FileReaderTool(this.server);
  
  @override
  String get name => 'read_file';
  
  @override
  String get description => 'Reads content from a file';
  
  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'path': {
        'type': 'string',
        'description': 'Path to the file to read'
      }
    },
    'required': ['path']
  };
  
  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final path = arguments['path'] as String;
    
    if (!server.isReadAllowed(path)) {
      throw Exception('Access denied to file: $path');
    }
    
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('File not found: $path');
    }
    
    try {
      final content = await file.readAsString();
      return 'File: $path\n${'=' * 40}\n$content';
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }
}

void main(List<String> args) {
  // Parse command line arguments or environment variables
  final allowedReadPaths = _getPathsFromArgs(args, '--read-paths') ?? 
      _getPathsFromEnv('MCP_READ_PATHS') ?? 
      [Directory.current.path]; // Default to current directory
  
  final allowedWritePaths = _getPathsFromArgs(args, '--write-paths') ?? 
      _getPathsFromEnv('MCP_WRITE_PATHS') ?? 
      [Directory.current.path];
  
  final reportOutputDir = _getArgValue(args, '--report-dir') ?? 
      Platform.environment['MCP_REPORT_DIR'];
  
  final server = FilesystemMCPServer(
    name: 'filesystem-mcp-server',
    allowedReadPaths: allowedReadPaths,
    allowedWritePaths: allowedWritePaths,
    reportOutputDir: reportOutputDir,
  );
  
  server.start();
}

List<String>? _getPathsFromArgs(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index >= 0 && index < args.length - 1) {
    return args[index + 1].split(',');
  }
  return null;
}

List<String>? _getPathsFromEnv(String envVar) {
  final value = Platform.environment[envVar];
  return value?.split(',');
}

String? _getArgValue(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index >= 0 && index < args.length - 1) {
    return args[index + 1];
  }
  return null;
}