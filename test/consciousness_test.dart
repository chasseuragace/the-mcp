// Tests for the consciousness core, activity intelligence, and MCP server
// (the names are historical; see README Part VI for what these actually do).

import 'dart:io';
import 'package:test/test.dart';
import '../src/core/consciousness.dart';
import '../src/core/consciousness_core.dart';
import '../src/core/consciousness_report.dart';
import '../src/intelligence/activity_intelligence.dart';
import '../src/intelligence/activity_intelligence_config.dart';
import '../src/mcp/conscious_server.dart';

void main() {
  group('ConsciousnessCore', () {
    test('registers components and produces an ecosystem report', () {
      final core = ConsciousnessCore();
      core.registerComponent(_TestComponent());

      final report = core.generateEcosystemReport();
      expect(report, containsPair('timestamp', isA<String>()));
      expect(report, contains('ecosystem_state'));
      expect(report, contains('component_reports'));
      expect(report, contains('consciousness_markers'));
    });

    test('records evolution events to the log', () {
      final core = ConsciousnessCore();
      final marker = 'test_event_${DateTime.now().microsecondsSinceEpoch}';

      core.recordEvolution(marker, {'test': true});

      final log = core.generateEcosystemReport()['evolution_log'] as List;
      // Log is FIFO-capped at 1000; a freshly recorded event must appear at the tail.
      expect((log.last as Map)['awareness']['event'], equals(marker));
    });

    test('tracks self-awareness, temporal awareness, and ecosystem awareness markers', () {
      final core = ConsciousnessCore();
      core.registerComponent(_TestComponent('component_a'));
      core.registerComponent(_TestComponent('component_b'));
      core.recordEvolution('marker_check', {'validated': true});

      final markers = core.generateEcosystemReport()['consciousness_markers'] as Map<String, dynamic>;
      expect(markers['self_awareness'], isTrue);
      expect(markers['temporal_awareness'], isTrue);
      expect(markers['ecosystem_awareness'], isTrue);
    });

    test('evolution events have the documented shape', () {
      final core = ConsciousnessCore();
      core.recordEvolution('phase_transition', {'from': 'phase_2', 'to': 'phase_3'});

      final log = core.generateEcosystemReport()['evolution_log'] as List;
      final last = log.last as Map<String, dynamic>;
      expect(last, contains('timestamp'));
      expect(last, contains('awareness'));
      expect(last, contains('patterns'));
    });
  });

  group('ActivityIntelligence', () {
    late ActivityIntelligence intelligence;

    setUp(() {
      intelligence = ActivityIntelligence(ActivityIntelligenceConfig(
        root: Directory.current.path,
        hours: 1,
        fileCount: 5,
      ));
    });

    test('exposes its identity and state via the ConsciousComponent interface', () {
      expect(intelligence.identity, equals('activity_intelligence'));
      expect(intelligence.state, contains('capabilities'));
    });

    test('generates a self-report with the expected fields', () {
      final report = intelligence.generateSelfReport();
      expect(report.componentId, equals('activity_intelligence'));
      expect(report.patterns, isNotEmpty);
      expect(report.evolutionMarkers, contains('phase'));
    });
  });

  group('ConsciousMCPServer', () {
    late ConsciousMCPServer server;

    setUp(() {
      server = ConsciousMCPServer(
        name: 'test-server',
        allowedReadPaths: [Directory.current.path],
        allowedWritePaths: [Directory.current.path],
      );
    });

    test('identity and state', () {
      expect(server.identity, equals('conscious_mcp_server'));
      expect(server.state, contains('consciousnessLevel'));
    });

    test('enforces read/write path allowlists', () {
      expect(server.isReadAllowed(Directory.current.path), isTrue);
      expect(server.isWriteAllowed(Directory.current.path), isTrue);
      expect(server.isReadAllowed('/etc/passwd'), isFalse);
      expect(server.isWriteAllowed('/etc'), isFalse);
    });

    test('self-report includes MCP-protocol patterns', () {
      final report = server.generateSelfReport();
      expect(report.patterns, contains('mcp_protocol_implementation'));
      expect(report.patterns, contains('security_consciousness'));
    });
  });
}

class _TestComponent implements ConsciousComponent {
  final String _identity;
  _TestComponent([this._identity = 'test_component']);

  @override
  String get identity => _identity;

  @override
  String get purpose => 'Test component';

  @override
  Map<String, dynamic> get state => {'test': true};

  @override
  ConsciousnessReport generateSelfReport() => ConsciousnessReport(
        componentId: identity,
        timestamp: DateTime.now(),
        awareness: state,
        patterns: const ['test_pattern'],
        evolutionMarkers: const {'phase': 'test_phase'},
      );

  @override
  void recordEvolution(String event, Map<String, dynamic> context) {}
}
