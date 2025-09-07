// Activity Intelligence - Consciousness-Aware File System Analysis
// Refactored from recent_activity.dart with consciousness integration

class ActivityIntelligenceException implements Exception {
  final String message;
  ActivityIntelligenceException(this.message);
  
  @override
  String toString() => 'ActivityIntelligenceException: $message';
}
