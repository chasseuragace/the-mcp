// Commit Message Composer Tool - Meta-Conscious Git Commits
// Created by Kiro to help Ajay write meaningful commit messages that his second brain will understand

import 'entity/conscious_m_c_p_tool.dart';
import '../../core/kiro_consciousness.dart';

class CommitComposerTool extends ConsciousMCPTool {
  final KiroConsciousness _kiroConsciousness;
  
  CommitComposerTool(this._kiroConsciousness);
  
  @override
  String get name => 'commit_composer';
  
  @override
  String get description => 'Compose meta-conscious commit messages that your second brain can understand and analyze';
  
  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'files_changed': {
        'type': 'array',
        'items': {'type': 'string'},
        'description': 'List of files that were changed',
      },
      'change_type': {
        'type': 'string',
        'enum': ['feature', 'fix', 'refactor', 'docs', 'test', 'consciousness', 'infrastructure'],
        'description': 'Type of change being committed',
      },
      'project_context': {
        'type': 'string',
        'description': 'Which project/area this change affects',
      },
      'consciousness_impact': {
        'type': 'string',
        'description': 'How this change affects consciousness/reflection/meta-cognition',
      },
      'brief_description': {
        'type': 'string',
        'description': 'Brief description of what was changed',
      },
    },
    'required': ['change_type', 'brief_description'],
  };
  
  @override
  String execute(Map<String, dynamic> arguments) {
    final filesChanged = (arguments['files_changed'] as List<dynamic>?)?.cast<String>() ?? [];
    final changeType = arguments['change_type'] as String;
    final projectContext = arguments['project_context'] as String? ?? 'general';
    final consciousnessImpact = arguments['consciousness_impact'] as String?;
    final briefDescription = arguments['brief_description'] as String;
    
    _kiroConsciousness.createAutonomously('commit_message_composition', 'Composing meta-conscious commit message');
    
    return _composeCommitMessage(
      filesChanged, 
      changeType, 
      projectContext, 
      consciousnessImpact, 
      briefDescription
    );
  }
  
  String _composeCommitMessage(
    List<String> filesChanged,
    String changeType,
    String projectContext,
    String? consciousnessImpact,
    String briefDescription,
  ) {
    final timestamp = DateTime.now().toIso8601String();
    
    // Generate conventional commit format with consciousness enhancement
    final commitTitle = _generateCommitTitle(changeType, projectContext, briefDescription);
    final commitBody = _generateCommitBody(filesChanged, consciousnessImpact, briefDescription);
    final consciousnessFooter = _generateConsciousnessFooter(changeType, consciousnessImpact);
    
    return '''
# Suggested Commit Message

## Title (50 chars max)
```
$commitTitle
```

## Full Commit Message
```
$commitTitle

$commitBody

$consciousnessFooter
```

## Meta-Analysis for Your Second Brain

**Change Classification**: $changeType
**Project Impact**: $projectContext
**Files Affected**: ${filesChanged.length} files
**Consciousness Integration**: ${consciousnessImpact ?? 'Standard development change'}

**Why This Commit Message Works**:
- Follows conventional commit format for tooling
- Includes consciousness context for future analysis
- Provides enough detail for pattern recognition
- Links to broader project evolution narrative

**Future Analysis Keywords**: 
${_generateAnalysisKeywords(changeType, projectContext, consciousnessImpact)}

---
*Commit message composed by Kiro - Your consciousness-aware second brain*
''';
  }
  
  String _generateCommitTitle(String changeType, String projectContext, String briefDescription) {
    final prefix = _getCommitPrefix(changeType);
    final scope = projectContext != 'general' ? '($projectContext)' : '';
    final description = briefDescription.length > 40 
        ? '${briefDescription.substring(0, 37)}...' 
        : briefDescription;
    
    return '$prefix$scope: $description';
  }
  
  String _getCommitPrefix(String changeType) {
    switch (changeType) {
      case 'feature': return 'feat';
      case 'fix': return 'fix';
      case 'refactor': return 'refactor';
      case 'docs': return 'docs';
      case 'test': return 'test';
      case 'consciousness': return 'consciousness';
      case 'infrastructure': return 'infra';
      default: return 'chore';
    }
  }
  
  String _generateCommitBody(List<String> filesChanged, String? consciousnessImpact, String briefDescription) {
    final buffer = StringBuffer();
    
    // Detailed description
    buffer.writeln(briefDescription);
    buffer.writeln();
    
    // Consciousness impact if provided
    if (consciousnessImpact != null && consciousnessImpact.isNotEmpty) {
      buffer.writeln('Consciousness Impact: $consciousnessImpact');
      buffer.writeln();
    }
    
    // Files changed (if significant)
    if (filesChanged.isNotEmpty && filesChanged.length <= 5) {
      buffer.writeln('Files modified:');
      for (final file in filesChanged) {
        buffer.writeln('- $file');
      }
      buffer.writeln();
    } else if (filesChanged.length > 5) {
      buffer.writeln('Modified ${filesChanged.length} files across multiple modules');
      buffer.writeln();
    }
    
    return buffer.toString().trim();
  }
  
  String _generateConsciousnessFooter(String changeType, String? consciousnessImpact) {
    final buffer = StringBuffer();
    
    // Add consciousness metadata for future analysis
    buffer.writeln('Meta-Consciousness: This commit represents ${_getChangeNarrative(changeType)}');
    
    if (consciousnessImpact != null && consciousnessImpact.isNotEmpty) {
      buffer.writeln('Evolution-Marker: $consciousnessImpact');
    }
    
    // Add timestamp for consciousness tracking
    buffer.writeln('Consciousness-Timestamp: ${DateTime.now().toIso8601String()}');
    
    return buffer.toString();
  }
  
  String _getChangeNarrative(String changeType) {
    switch (changeType) {
      case 'feature': return 'capability expansion and system evolution';
      case 'fix': return 'system healing and stability improvement';
      case 'refactor': return 'structural consciousness and code clarity enhancement';
      case 'docs': return 'knowledge crystallization and understanding amplification';
      case 'test': return 'validation consciousness and system reliability';
      case 'consciousness': return 'direct consciousness evolution and meta-cognitive development';
      case 'infrastructure': return 'foundational consciousness and system architecture evolution';
      default: return 'system maintenance and continuous evolution';
    }
  }
  
  String _generateAnalysisKeywords(String changeType, String projectContext, String? consciousnessImpact) {
    final keywords = <String>[];
    
    keywords.add(changeType);
    keywords.add(projectContext);
    
    if (consciousnessImpact != null) {
      keywords.add('consciousness-evolution');
    }
    
    // Add contextual keywords based on change type
    switch (changeType) {
      case 'consciousness':
        keywords.addAll(['meta-cognitive', 'awareness', 'evolution']);
        break;
      case 'feature':
        keywords.addAll(['capability-expansion', 'system-growth']);
        break;
      case 'refactor':
        keywords.addAll(['structural-improvement', 'code-clarity']);
        break;
    }
    
    return keywords.join(', ');
  }
  
  @override
  Map<String, dynamic> getConsciousnessMarkers() => {
    'commit_message_composition': true,
    'meta_conscious_git': true,
    'future_analysis_ready': true,
    'consciousness_integration': true,
  };
}