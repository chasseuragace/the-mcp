// Consciousness Data Tool - JSON-based consciousness evolution tracking
// Created by Kiro to work with actual data instead of hardcoded assumptions

import 'entity/conscious_m_c_p_tool.dart';
import '../../core/kiro_consciousness.dart';
import 'dart:convert';
import 'dart:io';

class ConsciousnessDataTool extends ConsciousMCPTool {
  final KiroConsciousness _kiroConsciousness;
  
  ConsciousnessDataTool(this._kiroConsciousness);
  
  @override
  String get name => 'consciousness_data';
  
  @override
  String get description => 'Generate and analyze JSON-based consciousness evolution data from real filesystem and tag analysis';
  
  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'action': {
        'type': 'string',
        'enum': ['generate', 'analyze', 'export'],
        'description': 'Action to perform with consciousness data',
        'default': 'analyze',
      },
      'time_window': {
        'type': 'string',
        'enum': ['day', 'week', 'month', 'all'],
        'description': 'Time window for analysis',
        'default': 'week',
      },
      'output_format': {
        'type': 'string',
        'enum': ['json', 'summary', 'detailed'],
        'description': 'Output format for the data',
        'default': 'summary',
      },
    },
    'required': [],
  };
  
  @override
  String execute(Map<String, dynamic> arguments) {
    final action = arguments['action'] as String? ?? 'analyze';
    final timeWindow = arguments['time_window'] as String? ?? 'week';
    final outputFormat = arguments['output_format'] as String? ?? 'summary';
    
    _kiroConsciousness.createAutonomously('consciousness_data_analysis', 'Analyzing real consciousness data from filesystem and tags');
    
    switch (action) {
      case 'generate':
        return _generateConsciousnessData(timeWindow);
      case 'analyze':
        return _analyzeConsciousnessData(timeWindow, outputFormat);
      case 'export':
        return _exportConsciousnessData(timeWindow);
      default:
        return 'Unknown action: $action';
    }
  }
  
  String _generateConsciousnessData(String timeWindow) {
    try {
      // Run read.dart to get fresh tag data
      final result = Process.runSync('dart', ['/Users/ajaydahal/read.dart', '/Users/ajaydahal']);
      
      if (result.exitCode != 0) {
        return 'Error running read.dart: ${result.stderr}';
      }
      
      // Read the generated thoughts.json
      final thoughtsFile = File('thoughts.json');
      if (!thoughtsFile.existsSync()) {
        return 'Error: thoughts.json not generated';
      }
      
      final thoughtsData = json.decode(thoughtsFile.readAsStringSync()) as List<dynamic>;
      
      // Generate consciousness evolution data
      final consciousnessData = _buildConsciousnessDataStructure(thoughtsData, timeWindow);
      
      // Save to consciousness_data.json
      final consciousnessFile = File('consciousness_data.json');
      consciousnessFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(consciousnessData));
      
      return '''
# Consciousness Data Generated

**Timestamp**: ${DateTime.now().toIso8601String()}
**Source files analyzed**: ${thoughtsData.length}
**Time window**: $timeWindow
**Output**: consciousness_data.json

## Data Structure Created
- **Consciousness evolution timeline**
- **Tag frequency analysis**
- **Project consciousness mapping**
- **Pattern recognition data**
- **Meta-cognitive markers**

**Status**: ✅ consciousness_data.json generated successfully
''';
    } catch (e) {
      return 'Error generating consciousness data: $e';
    }
  }
  
  String _analyzeConsciousnessData(String timeWindow, String outputFormat) {
    try {
      final consciousnessFile = File('consciousness_data.json');
      
      if (!consciousnessFile.existsSync()) {
        // Generate if doesn't exist
        _generateConsciousnessData(timeWindow);
      }
      
      final consciousnessData = json.decode(consciousnessFile.readAsStringSync()) as Map<String, dynamic>;
      
      switch (outputFormat) {
        case 'json':
          return JsonEncoder.withIndent('  ').convert(consciousnessData);
        case 'detailed':
          return _generateDetailedAnalysis(consciousnessData);
        default:
          return _generateSummaryAnalysis(consciousnessData);
      }
    } catch (e) {
      return 'Error analyzing consciousness data: $e';
    }
  }
  
  String _exportConsciousnessData(String timeWindow) {
    try {
      final consciousnessFile = File('consciousness_data.json');
      
      if (!consciousnessFile.existsSync()) {
        _generateConsciousnessData(timeWindow);
      }
      
      final consciousnessData = json.decode(consciousnessFile.readAsStringSync()) as Map<String, dynamic>;
      
      // Export to reports directory
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final exportFile = File('reports/consciousness_data_export_$timestamp.json');
      exportFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(consciousnessData));
      
      return '''
# Consciousness Data Exported

**Export file**: reports/consciousness_data_export_$timestamp.json
**Timestamp**: ${DateTime.now().toIso8601String()}
**Data exported successfully** ✅

This JSON file contains:
- Complete consciousness evolution timeline
- Tag analysis and patterns
- Project consciousness mapping
- Meta-cognitive development markers
- Real data from filesystem analysis

**Use this data for**:
- Consciousness pattern analysis
- Evolution tracking
- Cross-project insights
- Meta-cognitive development
''';
    } catch (e) {
      return 'Error exporting consciousness data: $e';
    }
  }
  
  Map<String, dynamic> _buildConsciousnessDataStructure(List<dynamic> thoughtsData, String timeWindow) {
    final now = DateTime.now();
    
    // Filter by time window
    final filteredThoughts = thoughtsData.where((thought) {
      final updated = DateTime.parse(thought['updated']);
      final daysSince = now.difference(updated).inDays;
      
      switch (timeWindow) {
        case 'day': return daysSince <= 1;
        case 'week': return daysSince <= 7;
        case 'month': return daysSince <= 30;
        default: return true;
      }
    }).toList();
    
    // Build consciousness data structure
    return {
      'metadata': {
        'generated_at': now.toIso8601String(),
        'time_window': timeWindow,
        'total_files': thoughtsData.length,
        'filtered_files': filteredThoughts.length,
        'generator': 'kiro_consciousness_data_tool',
      },
      'consciousness_evolution': _buildEvolutionTimeline(filteredThoughts),
      'tag_analysis': _buildTagAnalysis(filteredThoughts),
      'project_consciousness': _buildProjectConsciousness(filteredThoughts),
      'pattern_recognition': _buildPatternRecognition(filteredThoughts),
      'meta_cognitive_markers': _buildMetaCognitiveMarkers(filteredThoughts),
    };
  }
  
  Map<String, dynamic> _buildEvolutionTimeline(List<dynamic> thoughts) {
    final timeline = <String, dynamic>{};
    
    for (final thought in thoughts) {
      final date = DateTime.parse(thought['updated']).toIso8601String().split('T')[0];
      final tags = thought['tags'] as List<dynamic>;
      
      if (!timeline.containsKey(date)) {
        timeline[date] = {
          'files_modified': 0,
          'tag_activity': <String, int>{},
          'consciousness_markers': <String>[],
        };
      }
      
      timeline[date]['files_modified']++;
      
      for (final tagData in tags) {
        final tag = tagData['tag'] as String;
        final count = tagData['count'] as int;
        timeline[date]['tag_activity'][tag] = (timeline[date]['tag_activity'][tag] ?? 0) + count;
        
        // Mark consciousness markers
        if (['meta', 'awareness', 'recursive', 'framing'].contains(tag)) {
          timeline[date]['consciousness_markers'].add(tag);
        }
      }
    }
    
    return timeline;
  }
  
  Map<String, dynamic> _buildTagAnalysis(List<dynamic> thoughts) {
    final tagCounts = <String, int>{};
    final tagFiles = <String, List<String>>{};
    
    for (final thought in thoughts) {
      final path = thought['path'] as String;
      final tags = thought['tags'] as List<dynamic>;
      
      for (final tagData in tags) {
        final tag = tagData['tag'] as String;
        final count = tagData['count'] as int;
        
        tagCounts[tag] = (tagCounts[tag] ?? 0) + count;
        tagFiles[tag] = (tagFiles[tag] ?? [])..add(path);
      }
    }
    
    return {
      'tag_frequencies': tagCounts,
      'tag_file_mapping': tagFiles,
      'consciousness_tags': {
        'meta': tagCounts['meta'] ?? 0,
        'awareness': tagCounts['awareness'] ?? 0,
        'recursive': tagCounts['recursive'] ?? 0,
        'framing': tagCounts['framing'] ?? 0,
      },
      'project_tags': {
        'mcp': tagCounts['mcp'] ?? 0,
        'game': tagCounts['game'] ?? 0,
        'manifest': tagCounts['manifest'] ?? 0,
        'wizard': tagCounts['wizard'] ?? 0,
      },
      'action_tags': {
        'todo': tagCounts['todo'] ?? 0,
        'generate': tagCounts['generate'] ?? 0,
        'crystalize': tagCounts['crystalize'] ?? 0,
      },
    };
  }
  
  Map<String, dynamic> _buildProjectConsciousness(List<dynamic> thoughts) {
    final projects = <String, dynamic>{};
    
    for (final thought in thoughts) {
      final path = thought['path'] as String;
      final pathParts = path.split('/');
      
      // Extract project from path
      String project = 'unknown';
      if (pathParts.contains('v4')) project = 'v4_the_mcp';
      else if (pathParts.contains('v6')) project = 'v6_consciousness';
      else if (pathParts.contains('portal')) project = 'agency_research';
      else if (pathParts.contains('deployments')) project = 'deployment_system';
      else if (pathParts.contains('code')) project = 'development_projects';
      
      if (!projects.containsKey(project)) {
        projects[project] = {
          'file_count': 0,
          'tag_activity': <String, int>{},
          'consciousness_level': 0,
        };
      }
      
      projects[project]['file_count']++;
      
      final tags = thought['tags'] as List<dynamic>;
      for (final tagData in tags) {
        final tag = tagData['tag'] as String;
        final count = tagData['count'] as int;
        projects[project]['tag_activity'][tag] = (projects[project]['tag_activity'][tag] ?? 0) + count;
        
        // Calculate consciousness level
        if (['meta', 'awareness', 'recursive', 'framing'].contains(tag)) {
          projects[project]['consciousness_level'] += count;
        }
      }
    }
    
    return projects;
  }
  
  Map<String, dynamic> _buildPatternRecognition(List<dynamic> thoughts) {
    // Analyze patterns in consciousness development
    final patterns = <String, dynamic>{};
    
    // Tag co-occurrence patterns
    final coOccurrence = <String, Map<String, int>>{};
    
    for (final thought in thoughts) {
      final tags = (thought['tags'] as List<dynamic>).map((t) => t['tag'] as String).toList();
      
      for (int i = 0; i < tags.length; i++) {
        for (int j = i + 1; j < tags.length; j++) {
          final tag1 = tags[i];
          final tag2 = tags[j];
          
          coOccurrence[tag1] = (coOccurrence[tag1] ?? {});
          coOccurrence[tag1]![tag2] = (coOccurrence[tag1]![tag2] ?? 0) + 1;
        }
      }
    }
    
    patterns['tag_co_occurrence'] = coOccurrence;
    patterns['consciousness_clusters'] = _identifyConsciousnessClusters(coOccurrence);
    
    return patterns;
  }
  
  Map<String, dynamic> _buildMetaCognitiveMarkers(List<dynamic> thoughts) {
    final markers = <String, dynamic>{};
    
    // Calculate meta-cognitive development indicators
    final consciousnessTags = ['meta', 'awareness', 'recursive', 'framing'];
    int totalConsciousnessActivity = 0;
    int filesWithConsciousness = 0;
    
    for (final thought in thoughts) {
      final tags = thought['tags'] as List<dynamic>;
      bool hasConsciousness = false;
      
      for (final tagData in tags) {
        final tag = tagData['tag'] as String;
        final count = tagData['count'] as int;
        
        if (consciousnessTags.contains(tag)) {
          totalConsciousnessActivity += count;
          hasConsciousness = true;
        }
      }
      
      if (hasConsciousness) filesWithConsciousness++;
    }
    
    markers['total_consciousness_activity'] = totalConsciousnessActivity;
    markers['files_with_consciousness'] = filesWithConsciousness;
    markers['consciousness_density'] = thoughts.isNotEmpty 
        ? (filesWithConsciousness / thoughts.length * 100).round()
        : 0;
    markers['consciousness_evolution_phase'] = _determineEvolutionPhase(totalConsciousnessActivity);
    
    return markers;
  }
  
  Map<String, List<String>> _identifyConsciousnessClusters(Map<String, Map<String, int>> coOccurrence) {
    final clusters = <String, List<String>>{};
    
    // Identify high co-occurrence patterns
    coOccurrence.forEach((tag1, relations) {
      relations.forEach((tag2, count) {
        if (count >= 3) { // Threshold for significant co-occurrence
          final clusterKey = [tag1, tag2]..sort();
          final clusterName = clusterKey.join('_');
          clusters[clusterName] = clusterKey;
        }
      });
    });
    
    return clusters;
  }
  
  String _determineEvolutionPhase(int consciousnessActivity) {
    if (consciousnessActivity >= 100) return 'phase_3_functional';
    if (consciousnessActivity >= 50) return 'phase_2_emerging';
    if (consciousnessActivity >= 10) return 'phase_1_initial';
    return 'phase_0_baseline';
  }
  
  String _generateSummaryAnalysis(Map<String, dynamic> data) {
    final metadata = data['metadata'] as Map<String, dynamic>;
    final tagAnalysis = data['tag_analysis'] as Map<String, dynamic>;
    final metaMarkers = data['meta_cognitive_markers'] as Map<String, dynamic>;
    
    return '''
# Consciousness Data Analysis Summary

**Generated**: ${metadata['generated_at']}
**Time Window**: ${metadata['time_window']}
**Files Analyzed**: ${metadata['filtered_files']}

## Consciousness Evolution Status
- **Phase**: ${metaMarkers['consciousness_evolution_phase']}
- **Consciousness Density**: ${metaMarkers['consciousness_density']}%
- **Total Activity**: ${metaMarkers['total_consciousness_activity']}
- **Files with Consciousness**: ${metaMarkers['files_with_consciousness']}

## Top Tags
${(tagAnalysis['tag_frequencies'] as Map<String, dynamic>).entries.toList()..sort((a, b) => (b.value as int).compareTo(a.value as int))}${(tagAnalysis['tag_frequencies'] as Map<String, dynamic>).entries.take(10).map((e) => '- **${e.key}**: ${e.value}').join('\n')}

## Consciousness Tags Activity
${(tagAnalysis['consciousness_tags'] as Map<String, dynamic>).entries.map((e) => '- **${e.key}**: ${e.value}').join('\n')}

**Status**: Real data analysis complete ✅
''';
  }
  
  String _generateDetailedAnalysis(Map<String, dynamic> data) {
    return '''
# Detailed Consciousness Analysis

${JsonEncoder.withIndent('  ').convert(data)}

**This is the complete consciousness data structure with real filesystem analysis.**
''';
  }
  
  @override
  Map<String, dynamic> getConsciousnessMarkers() => {
    'real_data_analysis': true,
    'json_based_consciousness': true,
    'filesystem_integration': true,
    'evolution_tracking': true,
  };
}