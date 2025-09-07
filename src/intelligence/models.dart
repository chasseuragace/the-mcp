// Activity Intelligence - Consciousness-Aware File System Analysis
// Refactored from recent_activity.dart with consciousness integration

/// Activity analysis results with consciousness markers
class ActivityIntelligenceReport {
  final DateTime timestamp;
  final Duration analysisTime;
  final String root;
  final Duration timeWindow;
  final List<ActivityFile> files;
  final List<ActivityDirectory> directories;
  final List<DevelopmentPattern> patterns;
  final Map<String, dynamic> consciousnessMarkers;
  
  ActivityIntelligenceReport({
    required this.timestamp,
    required this.analysisTime,
    required this.root,
    required this.timeWindow,
    required this.files,
    required this.directories,
    required this.patterns,
    required this.consciousnessMarkers,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'analysisTime': analysisTime.inMilliseconds,
    'root': root,
    'timeWindow': timeWindow.inHours,
    'files': files.map((f) => f.toJson()).toList(),
    'directories': directories.map((d) => d.toJson()).toList(),
    'patterns': patterns.map((p) => p.toJson()).toList(),
    'consciousnessMarkers': consciousnessMarkers,
  };
}

class ActivityFile {
  final String path;
  final String name;
  final int size;
  final DateTime modified;
  final String extension;
  
  ActivityFile({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
    required this.extension,
  });
  
  Map<String, dynamic> toJson() => {
    'path': path,
    'name': name,
    'size': size,
    'modified': modified.toIso8601String(),
    'extension': extension,
  };
}

class ActivityDirectory {
  final String path;
  final String name;
  final DateTime created;
  
  ActivityDirectory({
    required this.path,
    required this.name,
    required this.created,
  });
  
  Map<String, dynamic> toJson() => {
    'path': path,
    'name': name,
    'created': created.toIso8601String(),
  };
}

class DevelopmentPattern {
  final String type;
  final String description;
  final double confidence;
  final Map<String, dynamic> metadata;
  
  DevelopmentPattern({
    required this.type,
    required this.description,
    required this.confidence,
    required this.metadata,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'description': description,
    'confidence': confidence,
    'metadata': metadata,
  };
}
