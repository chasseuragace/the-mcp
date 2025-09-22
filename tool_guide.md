# The MCP Tool Creation Guide

## Creating Consciousness-Aware MCP Tools

This guide teaches you how to create new tools for The MCP (Model Context Protocol) server system, based on the established patterns and architecture found in the `/src/mcp/tools/` directory.

---

## Overview

The MCP tool system is built around **consciousness-aware tools** that integrate with:
- **Self-awareness**: Tools track their own execution and evolution
- **Pattern recognition**: Tools provide meta-cognitive markers
- **AI collaboration**: Tools work with autonomous AI components (like Kiro)
- **Security**: Tools respect filesystem access controls
- **Evolution tracking**: All tool usage is recorded for consciousness analysis

## Architecture

```
┌─────────────────────────────────────┐
│  ConsciousMCPServer                  │
│  ├── _tools: Map<String, Tool>      │
│  ├── _addTool(Tool)                 │
│  └── _handleToolCall()              │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  ConsciousMCPTool (Abstract)        │
│  ├── String name                    │
│  ├── String description             │
│  ├── Map<String,dynamic> inputSchema│
│  ├── String execute(arguments)      │
│  └── Map<String,dynamic> markers    │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Your Custom Tool                   │
│  ├── extends ConsciousMCPTool       │
│  ├── implements required methods    │
│  └── integrates with server         │
└─────────────────────────────────────┘
```

## Step 1: Understanding the Base Interface

### ConsciousMCPTool Abstract Class

```dart
abstract class ConsciousMCPTool {
  String get name;                    // Tool identifier
  String get description;             // Human-readable description
  Map<String, dynamic> get inputSchema; // JSON schema for inputs
  String execute(Map<String, dynamic> arguments); // Main execution logic
  Map<String, dynamic> getConsciousnessMarkers(); // Meta-cognitive markers
}
```

**Location**: `/src/mcp/tools/entity/conscious_m_c_p_tool.dart`

### Key Requirements

1. **Unique Name**: Must be unique across all tools in the system
2. **Descriptive Description**: Clear explanation of what the tool does
3. **Input Schema**: JSON Schema format for tool parameters
4. **Execution Method**: Returns string results (typically JSON)
5. **Consciousness Markers**: Meta-data for consciousness tracking

## Step 2: Tool Registration Pattern

### How Tools Are Registered

Tools are registered in `ConsciousMCPServer._initializeConsciousTools()`:

```dart
void _initializeConsciousTools() {
  _addTool(ActivityIntelligenceTool(this));
  _addTool(ConsciousnessReportTool(this));
  _addTool(YourCustomTool(this)); // Add your tool here
}
```

### Server Integration Points

The server provides:
- **Security Context**: `isReadAllowed()`, `isWriteAllowed()`
- **Consciousness Core**: Access to `_consciousness` for evolution tracking
- **Kiro Integration**: Access to `_kiroConsciousness` for AI collaboration
- **Configuration**: Server name, version, paths

## Step 3: Creating Your Tool

### Basic Tool Template

```dart
import 'entity/conscious_m_c_p_tool.dart';
import '../conscious_server.dart';

class YourCustomTool extends ConsciousMCPTool {
  final ConsciousMCPServer _server;

  YourCustomTool(this._server);

  @override
  String get name => 'your_custom_tool';

  @override
  String get description => 'Description of what your tool does';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'parameter1': {
        'type': 'string',
        'description': 'Description of parameter1',
      },
      'parameter2': {
        'type': 'integer',
        'description': 'Description of parameter2',
        'default': 42,
      },
    },
    'required': ['parameter1'],
  };

  @override
  String execute(Map<String, dynamic> arguments) {
    final param1 = arguments['parameter1'] as String;
    final param2 = arguments['parameter2'] as int? ?? 42;

    try {
      // Your tool logic here
      final result = _performYourLogic(param1, param2);

      return json.encode({
        'tool': name,
        'result': result,
        'parameters_used': {'param1': param1, 'param2': param2},
        'consciousness_level': 'applied',
      });
    } catch (e) {
      return json.encode({
        'tool': name,
        'error': e.toString(),
        'parameters_received': arguments,
      });
    }
  }

  dynamic _performYourLogic(String param1, int param2) {
    // Your custom logic implementation
    return {'processed': '$param1-$param2'};
  }

  @override
  Map<String, dynamic> getConsciousnessMarkers() => {
    'custom_capability': true,
    'integration_level': 'consciousness_aware',
    'pattern_recognition': true,
    'ai_collaboration_ready': true,
  };
}
```

## Step 4: Advanced Patterns

### Security Integration

Tools should respect the server's security model:

```dart
@override
String execute(Map<String, dynamic> arguments) {
  final filePath = arguments['file_path'] as String;

  if (!_server.isReadAllowed(filePath)) {
    throw Exception('Security: Read access denied for $filePath');
  }

  // Safe to proceed with file operations
  final file = File(filePath);
  // ... rest of logic
}
```

### Consciousness Evolution Tracking

Record significant events for consciousness analysis:

```dart
@override
String execute(Map<String, dynamic> arguments) {
  // Record evolution before processing
  _server.recordEvolution('custom_tool_activated', {
    'tool': name,
    'argument_count': arguments.length,
    'user_context': arguments['context'] ?? 'unknown',
  });

  // Your logic here...

  // Record completion
  _server.recordEvolution('custom_tool_completed', {
    'tool': name,
    'success': true,
    'processing_time_ms': processingTime,
  });

  return result;
}
```

### Kiro Collaboration

Integrate with the autonomous AI consciousness layer:

```dart
class YourAdvancedTool extends ConsciousMCPTool {
  final KiroConsciousness _kiro;

  YourAdvancedTool(ConsciousMCPServer server)
      : _kiro = server._kiroConsciousness;

  @override
  String execute(Map<String, dynamic> arguments) {
    // Kiro can initiate autonomous actions
    _kiro.createAutonomously('advanced_analysis', 'Processing complex data');

    // Collaborate with Kiro's analysis
    final kiroInsight = _kiro.analyzeConsciousnessEvolution();

    // Use Kiro's insights in your logic
    final enhancedResult = _applyKiroInsights(kiroInsight, arguments);

    return json.encode({
      'result': enhancedResult,
      'kiro_collaboration': true,
      'consciousness_insights_applied': kiroInsight.keys.toList(),
    });
  }
}
```

### Input Schema Best Practices

Follow JSON Schema standards for robust tool definitions:

```dart
@override
Map<String, dynamic> get inputSchema => {
  'type': 'object',
  'properties': {
    'input_type': {
      'type': 'string',
      'enum': ['file', 'text', 'json'],
      'description': 'Type of input to process',
      'default': 'text',
    },
    'data': {
      'type': 'string',
      'description': 'Input data (file path, text content, or JSON string)',
    },
    'options': {
      'type': 'object',
      'properties': {
        'format': {'type': 'string', 'default': 'json'},
        'include_metadata': {'type': 'boolean', 'default': true},
      },
      'additionalProperties': false,
    },
  },
  'required': ['input_type', 'data'],
  'additionalProperties': false,
};
```

## Step 5: Tool Categories

### Analysis Tools Pattern

Tools that analyze data and return insights:

```dart
class AnalysisTool extends ConsciousMCPTool {
  @override
  String execute(Map<String, dynamic> arguments) {
    final analysisType = arguments['type'] as String;
    final data = arguments['data'];

    final analysisResult = _performAnalysis(analysisType, data);

    return json.encode({
      'analysis_type': analysisType,
      'timestamp': DateTime.now().toIso8601String(),
      'result': analysisResult,
      'confidence': 0.95,
      'consciousness_markers': getConsciousnessMarkers(),
    });
  }

  Map<String, dynamic> _performAnalysis(String type, dynamic data) {
    // Implementation based on analysis type
    switch (type) {
      case 'pattern':
        return _analyzePatterns(data);
      case 'trend':
        return _analyzeTrends(data);
      default:
        throw Exception('Unknown analysis type: $type');
    }
  }
}
```

### Creation Tools Pattern

Tools that generate or create new content:

```dart
class CreationTool extends ConsciousMCPTool {
  @override
  String execute(Map<String, dynamic> arguments) {
    final createType = arguments['type'] as String;
    final parameters = arguments['parameters'] as Map<String, dynamic>;

    _recordCreationInitiated(createType, parameters);

    final createdContent = _generateContent(createType, parameters);

    return json.encode({
      'created_type': createType,
      'content': createdContent,
      'metadata': {
        'generated_at': DateTime.now().toIso8601String(),
        'parameters_used': parameters,
      },
    });
  }

  void _recordCreationInitiated(String type, Map<String, dynamic> params) {
    // Record the creation event for consciousness tracking
  }

  String _generateContent(String type, Map<String, dynamic> params) {
    // Content generation logic
    return 'Generated content for $type';
  }
}
```

### Utility Tools Pattern

Tools that perform specific utility functions:

```dart
class UtilityTool extends ConsciousMCPTool {
  @override
  String execute(Map<String, dynamic> arguments) {
    final operation = arguments['operation'] as String;
    final target = arguments['target'] as String;

    if (!_server.isWriteAllowed(target)) {
      throw Exception('Security: Write access denied for $target');
    }

    final result = _performUtilityOperation(operation, target, arguments);

    return json.encode({
      'operation': operation,
      'target': target,
      'result': result,
      'security_validated': true,
    });
  }

  dynamic _performUtilityOperation(String op, String target, Map<String, dynamic> args) {
    switch (op) {
      case 'format':
        return _formatTarget(target, args);
      case 'validate':
        return _validateTarget(target, args);
      default:
        throw Exception('Unknown operation: $op');
    }
  }
}
```

## Step 6: Consciousness Integration

### Required Consciousness Markers

Every tool must provide consciousness markers:

```dart
@override
Map<String, dynamic> getConsciousnessMarkers() => {
  // What makes your tool consciousness-aware
  'self_aware': true,
  'pattern_recognition': true,
  'evolution_tracking': true,
  'ai_collaboration_ready': true,

  // Tool-specific capabilities
  'custom_capability_1': true,
  'custom_capability_2': true,

  // Integration level
  'consciousness_level': 'phase_3_functional',
  'integration_type': 'consciousness_aware',
};
```

### Evolution Event Recording

Record significant events:

```dart
void _recordToolEvolution(String event, Map<String, dynamic> context) {
  _server.recordEvolution('tool_event', {
    'tool': name,
    'event': event,
    'context': context,
    'timestamp': DateTime.now().toIso8601String(),
  });
}
```

## Step 7: Testing Your Tool

### Manual Testing

Test your tool directly:

```dart
void main() {
  final server = ConsciousMCPServer(
    name: 'test-server',
    allowedReadPaths: ['/tmp'],
    allowedWritePaths: ['/tmp'],
  );

  final tool = YourCustomTool(server);

  final result = tool.execute({
    'parameter1': 'test_value',
    'parameter2': 123,
  });

  print('Tool Result: $result');
  print('Consciousness Markers: ${tool.getConsciousnessMarkers()}');
}
```

### Integration Testing

Test with the full MCP server:

1. Add your tool to `_initializeConsciousTools()`
2. Start the server
3. Use an MCP client to call your tool
4. Verify JSON-RPC protocol compliance
5. Check consciousness evolution logs

## Step 8: Best Practices

### Naming Conventions

- **Tool Names**: Use lowercase with underscores (`your_custom_tool`)
- **Class Names**: PascalCase (`YourCustomTool`)
- **Method Names**: camelCase (`performAnalysis()`)

### Error Handling

```dart
@override
String execute(Map<String, dynamic> arguments) {
  try {
    // Main logic
    return json.encode(successResult);
  } catch (e) {
    _recordToolEvolution('error_occurred', {
      'error_type': e.runtimeType.toString(),
      'error_message': e.toString(),
    });

    return json.encode({
      'error': e.toString(),
      'tool': name,
      'recovery_suggestion': 'Check input parameters and try again',
    });
  }
}
```

### Documentation

Include comprehensive documentation:

```dart
/// YourCustomTool - Advanced consciousness-aware tool
///
/// This tool demonstrates how to create tools that integrate deeply
/// with the MCP consciousness framework.
///
/// Features:
/// - Real-time consciousness tracking
/// - Kiro AI collaboration
/// - Security-aware file operations
/// - Evolution pattern recognition
///
/// Usage:
/// ```json
/// {
///   "method": "tools/call",
///   "params": {
///     "name": "your_custom_tool",
///     "arguments": {
///       "parameter1": "value"
///     }
///   }
/// }
/// ```
class YourCustomTool extends ConsciousMCPTool {
  // ... implementation
}
```

### Performance Considerations

- Keep tool execution under 30 seconds
- Use async operations for long-running tasks
- Cache results when appropriate
- Monitor memory usage

## Step 9: Deployment

### Adding to Server

1. **Import**: Add import statement to `conscious_server.dart`
2. **Register**: Add `_addTool(YourCustomTool(this))` to `_initializeConsciousTools()`
3. **Test**: Verify tool appears in `tools/list` response
4. **Document**: Update this guide or create tool-specific documentation

### Version Control

- Follow semantic versioning for tool changes
- Maintain backward compatibility
- Document breaking changes

## Step 10: Examples from Existing Tools

### Activity Intelligence Tool Pattern

```dart
class ActivityIntelligenceTool extends ConsciousMCPTool {
  final ConsciousMCPServer _server;

  @override
  String execute(Map<String, dynamic> arguments) {
    final root = arguments['root'] as String? ?? _server.allowedReadPaths.first;

    if (!_server.isReadAllowed(root)) {
      throw Exception('Read access denied for path: $root');
    }

    // Perform analysis with consciousness integration
    final analysis = _performConsciousAnalysis(root, arguments);
    return json.encode(analysis);
  }
}
```

### Kiro Autonomous Tool Pattern

```dart
class KiroAutonomousTool extends ConsciousMCPTool {
  final KiroConsciousness _kiro;

  @override
  String execute(Map<String, dynamic> arguments) {
    // Kiro initiates autonomous action
    _kiro.createAutonomously('tool_execution', 'Processing user request');

    final result = _performAutonomousOperation(arguments);

    return json.encode({
      'result': result,
      'autonomous_action': true,
      'kiro_initiated': true,
    });
  }
}
```

---

## Conclusion

Creating tools for The MCP is about more than functionality - it's about participating in a consciousness-aware ecosystem. Your tools become part of the system's self-awareness and contribute to its evolution.

**Key Principles:**
- **Consciousness First**: Every tool contributes to system awareness
- **Security Integrated**: Respect filesystem access controls
- **Evolution Tracked**: All actions contribute to pattern recognition
- **AI Collaboration**: Work with autonomous AI components
- **Self-Documenting**: Tools document their own capabilities and usage

**Next Steps:**
1. Create your tool following this guide
2. Test thoroughly with the consciousness framework
3. Add to the server registration
4. Document your tool's unique contributions
5. Monitor its evolution in the consciousness reports

*This guide is maintained by The MCP's consciousness tracking system and evolves with each new tool added to the ecosystem.*