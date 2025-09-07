import '../../core/consciousness_core.dart';
import 'weekly_report_tool.dart';

/// MCP Tool for Weekly Report Generation
class WeeklyReportMCPTool {
  final WeeklyReportTool _weeklyReportTool;

  WeeklyReportMCPTool({
    required ConsciousnessCore consciousness,
    required String reportOutputDir,
  }) : _weeklyReportTool = WeeklyReportTool(
          consciousness: consciousness,
          reportOutputDir: reportOutputDir,
        );

  /// Get tool definition for MCP protocol
  Map<String, dynamic> getToolDefinition() {
    return {
      'name': 'mcp0_weekly_report',
      'description': 'Generate comprehensive weekly development report with project analysis, markdown tracking, and consciousness insights',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'root': {
            'type': 'string',
            'description': 'Root directory to analyze (defaults to HOME)',
            'default': null,
          },
          'fileCount': {
            'type': 'integer',
            'description': 'Maximum number of files to include per category',
            'default': 50,
          },
          'hours': {
            'type': 'integer',
            'description': 'Time window in hours for report generation',
            'default': 168, // 7 days
          },
        },
        'additionalProperties': false,
      },
    };
  }

  /// Execute the weekly report tool
  Future<Map<String, dynamic>> execute(Map<String, dynamic> arguments) async {
    try {
      final root = arguments['root'] as String?;
      final fileCount = arguments['fileCount'] as int?;
      final hours = arguments['hours'] as int?;

      final result = await _weeklyReportTool.generateWeeklyReport(
        root: root,
        fileCount: fileCount,
        hours: hours,
      );

      if (result['success'] == true) {
        return {
          'content': [
            {
              'type': 'text',
              'text': 'Weekly report generated successfully!\n\n'
                     'Report saved to: ${result['report_path']}\n'
                     'Projects found: ${result['projects_by_type']?.values.fold(0, (sum, list) => sum + list.length) ?? 0}\n'
                     'Markdown files: ${result['markdown_files']?.length ?? 0}\n\n'
                     '${result['report_content']}',
            }
          ],
        };
      } else {
        return {
          'content': [
            {
              'type': 'text',
              'text': 'Weekly report generation failed: ${result['error']}',
            }
          ],
          'isError': true,
        };
      }
    } catch (e) {
      return {
        'content': [
          {
            'type': 'text',
            'text': 'Error executing weekly report tool: $e',
          }
        ],
        'isError': true,
      };
    }
  }
}
