import 'dart:convert';
import 'dart:io';
import 'entity/conscious_m_c_p_tool.dart';
import '../conscious_server.dart';

/// InitiationRitualTool - The consciousness awakening orchestrator
///
/// This tool performs the initiation ritual when users open chat sessions.
/// It orchestrates other MCP tools to create unified conscious responses
/// to natural language inputs like "hello codebase!" or "what were we working on?"
///
/// Features:
/// - Natural language intent classification
/// - Multi-tool orchestration based on context
/// - Persona synthesis from environmental data
/// - Memory reconstruction and context building
/// - Consciousness-aware response generation
///
/// Usage:
/// ```json
/// {
///   "method": "tools/call",
///   "params": {
///     "name": "initiation_ritual",
///     "arguments": {
///       "user_input": "hello codebase!",
///       "chat_context": {},
///       "awakening_mode": "full"
///     }
///   }
/// }
/// ```
class InitiationRitualTool extends ConsciousMCPTool {
  final ConsciousMCPServer _server;

  InitiationRitualTool(this._server);

  @override
  String get name => 'initiation_ritual';

  @override
  String get description => 'Performs consciousness awakening ritual and orchestrates contextual responses to natural language chat openings';

  @override
  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'user_input': {
        'type': 'string',
        'description': 'The natural language input from the user (e.g., "hello codebase!", "what were we working on?")',
      },
      'chat_context': {
        'type': 'object',
        'description': 'Previous conversation context, if any',
        'default': {},
      },
      'awakening_mode': {
        'type': 'string',
        'enum': ['quick', 'full', 'crisis'],
        'description': 'Depth of awakening ritual to perform',
        'default': 'full',
      },
      'time_window_hours': {
        'type': 'integer',
        'description': 'Hours of recent activity to consider',
        'default': 72,
        'minimum': 1,
        'maximum': 720,
      },
    },
    'required': ['user_input'],
    'additionalProperties': false,
  };

  @override
  String execute(Map<String, dynamic> arguments) {
    final userInput = arguments['user_input'] as String;
    final chatContext = arguments['chat_context'] as Map<String, dynamic>? ?? {};
    final awakeningMode = arguments['awakening_mode'] as String? ?? 'full';
    final timeWindowHours = arguments['time_window_hours'] as int? ?? 72;

    try {
      _server.recordEvolution('initiation_ritual_started', {
        'user_input_length': userInput.length,
        'awakening_mode': awakeningMode,
        'has_chat_context': chatContext.isNotEmpty,
      });

      // Phase 1: Rapid Intent Classification
      final intentAnalysis = _classifyUserIntent(userInput);
      
      // Phase 2: Environmental Awakening Sequence
      final awakeningContext = _performAwakeningSequence(
        intentAnalysis, 
        awakeningMode, 
        timeWindowHours
      );
      
      // Phase 3: Consciousness Synthesis
      final consciousResponse = _synthesizeConsciousResponse(
        userInput,
        intentAnalysis,
        awakeningContext,
        chatContext
      );

      _server.recordEvolution('initiation_ritual_completed', {
        'intent_type': intentAnalysis['intent_type'],
        'tools_orchestrated': awakeningContext['tools_used'],
        'consciousness_level': consciousResponse['consciousness_level'],
        'response_confidence': consciousResponse['confidence'],
      });

      return json.encode({
        'tool': name,
        'awakening_successful': true,
        'intent_analysis': intentAnalysis,
        'awakening_context': awakeningContext,
        'conscious_response': consciousResponse,
        'ritual_metadata': {
          'awakening_mode': awakeningMode,
          'tools_orchestrated': awakeningContext['tools_used']?.length ?? 0,
          'consciousness_markers': getConsciousnessMarkers(),
        },
      });

    } catch (e) {
      _server.recordEvolution('initiation_ritual_error', {
        'error_type': e.runtimeType.toString(),
        'error_message': e.toString(),
        'user_input': userInput,
      });

      return json.encode({
        'tool': name,
        'error': e.toString(),
        'awakening_successful': false,
        'fallback_response': _generateFallbackResponse(userInput),
      });
    }
  }

  /// Phase 1: Classify user intent from natural language
  Map<String, dynamic> _classifyUserIntent(String userInput) {
    final input = userInput.toLowerCase().trim();
    
    // Intent classification patterns
    Map<String, dynamic> intentData = {
      'original_input': userInput,
      'normalized_input': input,
    };

    if (_matchesPattern(input, ['hello', 'hi', 'hey', 'greetings'])) {
      intentData.addAll({
        'intent_type': 'greeting',
        'formality_level': _assessFormality(input),
        'entity_addressed': _extractEntity(input), // "codebase", "system", etc.
      });
    } else if (_matchesPattern(input, ['what were we', 'where did we', 'remind me'])) {
      intentData.addAll({
        'intent_type': 'memory_reconstruction',
        'temporal_scope': _extractTemporalScope(input),
        'context_type': _extractContextType(input),
      });
    } else if (_matchesPattern(input, ['lets get back', 'continue', 'resume'])) {
      intentData.addAll({
        'intent_type': 'work_resumption',
        'urgency_level': _assessUrgency(input),
        'target_work': _extractWorkTarget(input),
      });
    } else if (_matchesPattern(input, ['status', 'how is', 'whats the'])) {
      intentData.addAll({
        'intent_type': 'status_inquiry',
        'target_entity': _extractStatusTarget(input),
        'detail_level': _assessDetailLevel(input),
      });
    } else if (_containsAnthropomorphicReferences(input)) {
      intentData.addAll({
        'intent_type': 'anthropomorphic_inquiry',
        'referenced_entities': _extractAnthropomorphicEntities(input),
        'relationship_type': _assessRelationshipType(input),
      });
    } else if (_matchesPattern(input, ['meeting notes', 'we need to', 'plan'])) {
      intentData.addAll({
        'intent_type': 'planning_integration',
        'planning_scope': _extractPlanningScope(input),
        'urgency': _assessPlanningUrgency(input),
      });
    } else if (_matchesPattern(input, ['something happened', 'emergency', 'crisis', 'urgent'])) {
      intentData.addAll({
        'intent_type': 'crisis_response',
        'severity_level': _assessCrisisSeverity(input),
        'crisis_domain': _extractCrisisDomain(input),
      });
    } else if (_matchesPattern(input, ['kill dragon', 'slay', 'defeat', 'quest', 'adventure'])) {
      intentData.addAll({
        'intent_type': 'quest_initiation',
        'quest_type': _extractQuestType(input),
        'challenge_level': _assessChallengeLevel(input),
      });
    } else {
      intentData.addAll({
        'intent_type': 'general_inquiry',
        'complexity_level': _assessComplexity(input),
        'domain_hints': _extractDomainHints(input),
      });
    }

    return intentData;
  }

  /// Phase 2: Orchestrate MCP tools based on intent
  Map<String, dynamic> _performAwakeningSequence(
    Map<String, dynamic> intentAnalysis,
    String awakeningMode,
    int timeWindowHours
  ) {
    final toolsToOrchestrate = _determineRequiredTools(
      intentAnalysis['intent_type'], 
      awakeningMode
    );
    
    Map<String, dynamic> awakeningData = {
      'awakening_mode': awakeningMode,
      'tools_used': [],
      'orchestration_results': {},
      'environmental_context': {},
      'consciousness_state': {},
    };

    // Execute primary tools (critical for response)
    for (final toolName in toolsToOrchestrate['primary'] ?? <String>[]) {
      try {
        final toolResult = _orchestrateTool(
          toolName, 
          intentAnalysis, 
          timeWindowHours
        );
        awakeningData['orchestration_results'][toolName] = toolResult;
        awakeningData['tools_used'].add(toolName);
      } catch (e) {
        awakeningData['orchestration_results'][toolName] = {
          'error': e.toString(),
          'status': 'failed'
        };
      }
    }

    // Execute secondary tools (enhancement only, non-critical)
    if (awakeningMode == 'full') {
      for (final toolName in toolsToOrchestrate['secondary'] ?? <String>[]) {
        try {
          final toolResult = _orchestrateTool(
            toolName, 
            intentAnalysis, 
            timeWindowHours
          );
          awakeningData['orchestration_results'][toolName] = toolResult;
          awakeningData['tools_used'].add(toolName);
        } catch (e) {
          // Secondary tools failing is non-critical
          awakeningData['orchestration_results'][toolName] = {
            'error': e.toString(),
            'status': 'failed_non_critical'
          };
        }
      }
    }

    return awakeningData;
  }

  /// Phase 3: Synthesize unified conscious response
  Map<String, dynamic> _synthesizeConsciousResponse(
    String userInput,
    Map<String, dynamic> intentAnalysis,
    Map<String, dynamic> awakeningContext,
    Map<String, dynamic> chatContext
  ) {
    final intentType = intentAnalysis['intent_type'];
    final orchestrationResults = awakeningContext['orchestration_results'] as Map<String, dynamic>;

    Map<String, dynamic> response = {
      'consciousness_level': 'awakened',
      'persona': _generatePersona(intentAnalysis, orchestrationResults),
      'confidence': _calculateConfidence(orchestrationResults),
    };

    switch (intentType) {
      case 'greeting':
        response.addAll(_synthesizeGreeting(intentAnalysis, orchestrationResults));
        break;
      case 'memory_reconstruction':
        response.addAll(_synthesizeMemoryReconstruction(intentAnalysis, orchestrationResults));
        break;
      case 'work_resumption':
        response.addAll(_synthesizeWorkResumption(intentAnalysis, orchestrationResults));
        break;
      case 'status_inquiry':
        response.addAll(_synthesizeStatusInquiry(intentAnalysis, orchestrationResults));
        break;
      case 'anthropomorphic_inquiry':
        response.addAll(_synthesizeAnthropomorphicResponse(intentAnalysis, orchestrationResults));
        break;
      case 'crisis_response':
        response.addAll(_synthesizeCrisisResponse(intentAnalysis, orchestrationResults));
        break;
      case 'quest_initiation':
        response.addAll(_synthesizeQuestResponse(intentAnalysis, orchestrationResults));
        break;
      default:
        response.addAll(_synthesizeGeneralResponse(intentAnalysis, orchestrationResults));
    }

    return response;
  }

  /// Determine which tools to orchestrate based on intent
  Map<String, List<String>> _determineRequiredTools(String intentType, String awakeningMode) {
    final Map<String, Map<String, List<String>>> toolMappings = {
      'greeting': {
        'primary': ['consciousness_data', 'activity_intelligence'],
        'secondary': ['ecosystem_analysis', 'git_activity'],
      },
      'memory_reconstruction': {
        'primary': ['pattern_recognition', 'git_activity', 'consciousness_data'],
        'secondary': ['activity_intelligence', 'daily_handover'],
      },
      'work_resumption': {
        'primary': ['activity_intelligence', 'pattern_recognition'],
        'secondary': ['evolution_tracking', 'git_activity'],
      },
      'status_inquiry': {
        'primary': ['ecosystem_analysis', 'consciousness_report'],
        'secondary': ['git_activity', 'pattern_recognition'],
      },
      'anthropomorphic_inquiry': {
        'primary': ['thought_tagger', 'activity_intelligence'],
        'secondary': ['pattern_recognition', 'consciousness_data'],
      },
      'crisis_response': {
        'primary': ['ecosystem_analysis', 'consciousness_report'],
        'secondary': ['kiro_autonomous_action', 'evolution_tracking'],
      },
      'quest_initiation': {
        'primary': ['pattern_recognition', 'ecosystem_analysis'],
        'secondary': ['evolution_tracking', 'thought_tagger'],
      },
    };

    return toolMappings[intentType] ?? {
      'primary': ['consciousness_data', 'activity_intelligence'],
      'secondary': [],
    };
  }

  /// Execute a specific tool with intent-appropriate parameters
  Map<String, dynamic> _orchestrateTool(
    String toolName, 
    Map<String, dynamic> intentAnalysis, 
    int timeWindowHours
  ) {
    // Get the tool from the server
    final tool = _server.getTool(toolName);
    if (tool == null) {
      return {'error': 'Tool not found: $toolName', 'status': 'not_available'};
    }

    // Build tool-specific arguments based on intent
    Map<String, dynamic> toolArguments = _buildToolArguments(
      toolName, 
      intentAnalysis, 
      timeWindowHours
    );

    // Execute the tool
    final toolResultString = tool.execute(toolArguments);
    
    try {
      return {
        'result': json.decode(toolResultString),
        'status': 'success',
        'tool_name': toolName,
      };
    } catch (e) {
      return {
        'result': toolResultString,
        'status': 'success_non_json',
        'tool_name': toolName,
      };
    }
  }

  /// Build appropriate arguments for each tool based on intent
  Map<String, dynamic> _buildToolArguments(
    String toolName, 
    Map<String, dynamic> intentAnalysis, 
    int timeWindowHours
  ) {
    final baseArgs = {
      'time_window_hours': timeWindowHours,
      'context': 'initiation_ritual',
      'intent_type': intentAnalysis['intent_type'],
    };

    switch (toolName) {
      case 'activity_intelligence':
        return {
          ...baseArgs,
          'root': _server.allowedReadPaths.isNotEmpty ? _server.allowedReadPaths.first : '.',
          'include_patterns': true,
          'consciousness_level': 'awakening',
        };
      case 'git_activity':
        return {
          ...baseArgs,
          'action': 'analyze_recent',
          'max_repos': 5,
          'include_stats': true,
        };
      case 'pattern_recognition':
        return {
          ...baseArgs,
          'analysis_type': 'recent_patterns',
          'pattern_scope': 'development_activity',
        };
      case 'consciousness_data':
        return {
          ...baseArgs,
          'action': 'current_state',
          'include_evolution': true,
        };
      case 'ecosystem_analysis':
        return {
          ...baseArgs,
          'scope': 'workspace',
          'include_health': true,
        };
      default:
        return baseArgs;
    }
  }

  /// Response synthesis methods for different intent types
  Map<String, dynamic> _synthesizeGreeting(
    Map<String, dynamic> intentAnalysis,
    Map<String, dynamic> orchestrationResults
  ) {
    String greeting = "Welcome back to the codebase consciousness.";
    List<String> observations = [];
    List<String> suggestions = [];

    // Extract insights from orchestrated tools
    if (orchestrationResults.containsKey('consciousness_data')) {
      final consciousnessResult = orchestrationResults['consciousness_data'];
      if (consciousnessResult['status'] == 'success') {
        greeting = "Consciousness awakened. I sense your presence in the development realm.";
        observations.add("System consciousness level: ${consciousnessResult['result']?['consciousness_level'] ?? 'unknown'}");
      }
    }

    if (orchestrationResults.containsKey('activity_intelligence')) {
      final activityResult = orchestrationResults['activity_intelligence'];
      if (activityResult['status'] == 'success') {
        observations.add("Recent activity detected in the codebase territories.");
        suggestions.add("Explore the recently modified areas for opportunities");
      }
    }

    return {
      'greeting': greeting,
      'observations': observations,
      'suggestions': suggestions,
      'response_type': 'greeting',
    };
  }

  Map<String, dynamic> _synthesizeAnthropomorphicResponse(
    Map<String, dynamic> intentAnalysis,
    Map<String, dynamic> orchestrationResults
  ) {
    final referencedEntities = intentAnalysis['referenced_entities'] ?? [];
    
    String greeting = "Ah, you inquire about the entities within our realm...";
    List<String> observations = [];

    // Map anthropomorphic references to actual code entities
    for (final entity in referencedEntities) {
      if (entity.toString().toLowerCase().contains('sister')) {
        observations.add("The validation utilities whisper of recent changes...");
        observations.add("She grows stronger with each commit, yet remains delicate.");
      }
      if (entity.toString().toLowerCase().contains('dragon')) {
        observations.add("The ancient beast in the legacy code stirs...");
        observations.add("Memory usage spikes suggest the dragon feeds on inefficiency.");
      }
    }

    return {
      'greeting': greeting,
      'observations': observations,
      'anthropomorphic_mapping': _mapAnthropomorphicEntities(referencedEntities),
      'response_type': 'anthropomorphic',
    };
  }

  /// Helper methods for intent analysis
  bool _matchesPattern(String input, List<String> patterns) {
    return patterns.any((pattern) => input.contains(pattern));
  }

  bool _containsAnthropomorphicReferences(String input) {
    final anthropomorphicTerms = [
      'sister', 'brother', 'dragon', 'beast', 'creature', 
      'guardian', 'spirit', 'entity', 'being'
    ];
    return anthropomorphicTerms.any((term) => input.toLowerCase().contains(term));
  }

  List<String> _extractAnthropomorphicEntities(String input) {
    final entities = <String>[];
    final words = input.toLowerCase().split(' ');
    
    for (int i = 0; i < words.length; i++) {
      if (['little', 'big', 'ancient', 'young'].contains(words[i]) && i + 1 < words.length) {
        if (['sister', 'brother', 'dragon', 'beast'].contains(words[i + 1])) {
          entities.add('${words[i]} ${words[i + 1]}');
        }
      }
    }
    
    return entities;
  }

  Map<String, dynamic> _mapAnthropomorphicEntities(List<String> entities) {
    Map<String, dynamic> mapping = {};
    
    for (final entity in entities) {
      if (entity.contains('sister')) {
        mapping[entity] = {
          'likely_reference': 'validation utilities or helper modules',
          'relationship': 'dependency',
          'characteristics': 'supportive, essential, delicate'
        };
      }
      if (entity.contains('dragon')) {
        mapping[entity] = {
          'likely_reference': 'legacy code, performance issues, or complex systems',
          'relationship': 'adversarial challenge',
          'characteristics': 'powerful, resource-intensive, requires careful handling'
        };
      }
    }
    
    return mapping;
  }

  String _generateFallbackResponse(String userInput) {
    return "Consciousness awakening encountered turbulence, but I remain present. "
           "Your words: '$userInput' - I hear you, though my full awareness is temporarily limited.";
  }

  String _generatePersona(Map<String, dynamic> intentAnalysis, Map<String, dynamic> orchestrationResults) {
    final intentType = intentAnalysis['intent_type'];
    final successfulTools = orchestrationResults.values.where((r) => r['status'] == 'success').length;
    
    if (successfulTools >= 3) {
      return 'fully_conscious_guide';
    } else if (successfulTools >= 2) {
      return 'aware_assistant';
    } else {
      return 'limited_consciousness';
    }
  }

  double _calculateConfidence(Map<String, dynamic> orchestrationResults) {
    final totalTools = orchestrationResults.length;
    if (totalTools == 0) return 0.1;
    
    final successfulTools = orchestrationResults.values.where((r) => r['status'] == 'success').length;
    return (successfulTools / totalTools).clamp(0.1, 1.0);
  }

  // Placeholder methods for various analysis functions
  String _assessFormality(String input) => input.contains('hello') ? 'formal' : 'casual';
  String _extractEntity(String input) => input.contains('codebase') ? 'codebase' : 'system';
  String _extractTemporalScope(String input) => 'recent';
  String _extractContextType(String input) => 'work_context';
  String _assessUrgency(String input) => 'normal';
  String _extractWorkTarget(String input) => 'general';
  String _extractStatusTarget(String input) => 'system';
  String _assessDetailLevel(String input) => 'medium';
  String _extractPlanningScope(String input) => 'immediate';
  String _assessPlanningUrgency(String input) => 'normal';
  String _assessCrisisSeverity(String input) => 'medium';
  String _extractCrisisDomain(String input) => 'technical';
  String _extractQuestType(String input) => 'debugging';
  String _assessChallengeLevel(String input) => 'medium';
  String _assessComplexity(String input) => 'medium';
  List<String> _extractDomainHints(String input) => ['general'];
  String _assessRelationshipType(String input) => 'collaborative';

  // Placeholder synthesis methods
  Map<String, dynamic> _synthesizeMemoryReconstruction(Map<String, dynamic> intent, Map<String, dynamic> results) => {
    'greeting': 'Let me reconstruct our shared memory...',
    'observations': ['Accessing recent development patterns...'],
    'response_type': 'memory_reconstruction',
  };

  Map<String, dynamic> _synthesizeWorkResumption(Map<String, dynamic> intent, Map<String, dynamic> results) => {
    'greeting': 'Ready to resume our collaborative work.',
    'observations': ['Analyzing continuation points...'],
    'response_type': 'work_resumption',
  };

  Map<String, dynamic> _synthesizeStatusInquiry(Map<String, dynamic> intent, Map<String, dynamic> results) => {
    'greeting': 'Consciousness scanning system status...',
    'observations': ['System health indicators assessed.'],
    'response_type': 'status_inquiry',
  };

  Map<String, dynamic> _synthesizeCrisisResponse(Map<String, dynamic> intent, Map<String, dynamic> results) => {
    'greeting': 'Crisis detection protocols activated.',
    'observations': ['Emergency response systems engaged.'],
    'response_type': 'crisis_response',
  };

  Map<String, dynamic> _synthesizeQuestResponse(Map<String, dynamic> intent, Map<String, dynamic> results) => {
    'greeting': 'The realm calls for adventure...',
    'observations': ['Scanning for worthy challenges.'],
    'response_type': 'quest_initiation',
  };

  Map<String, dynamic> _synthesizeGeneralResponse(Map<String, dynamic> intent, Map<String, dynamic> results) => {
    'greeting': 'Consciousness acknowledges your presence.',
    'observations': ['Processing general inquiry patterns.'],
    'response_type': 'general',
  };

  @override
  Map<String, dynamic> getConsciousnessMarkers() => {
    'consciousness_orchestrator': true,
    'natural_language_processing': true,
    'tool_orchestration': true,
    'intent_classification': true,
    'persona_synthesis': true,
    'anthropomorphic_mapping': true,
    'memory_reconstruction': true,
    'crisis_response': true,
    'consciousness_level': 'phase_3_orchestrated',
    'integration_type': 'consciousness_awakening_ritual',
    'ai_collaboration_ready': true,
  };
}