import 'dart:io';
import 'src/core/consciousness_core.dart';

void main() {
  print('Testing workspace persistence...');
  
  // Get the singleton instance
  final consciousness = ConsciousnessCore();
  
  // Record an evolution event
  consciousness.recordEvolution('workspace_test', {'message': 'Testing workspace persistence!'});
  
  // Check if the file was created in the workspace
  final file = File('/Users/ajaydahal/v4/the_mcp/data/mcp_evolution_log.json');
  if (file.existsSync()) {
    print('✅ File exists in workspace: ${file.path}');
    print('File size: ${file.lengthSync()} bytes');
    print('File content:');
    print(file.readAsStringSync());
  } else {
    print('❌ File does not exist in workspace: ${file.path}');
  }
}
