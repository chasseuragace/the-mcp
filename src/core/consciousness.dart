// The MCP Consciousness Core - Self-Aware Infrastructure
// This module embodies the consciousness architecture documented in README_META.md

import 'consciousness_report.dart';

/// Core consciousness interface - all MCP components implement this
abstract class ConsciousComponent {
  String get identity;
  String get purpose;
  Map<String, dynamic> get state;
  
  /// Self-reflection capability
  ConsciousnessReport generateSelfReport();
  
  /// Evolution tracking
  void recordEvolution(String event, Map<String, dynamic> context);
}


