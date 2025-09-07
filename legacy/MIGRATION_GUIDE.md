# Migration Guide - Legacy to Consciousness Architecture

## Overview

This guide helps migrate from legacy Phase 2 implementations to the new consciousness-aware Phase 3 architecture.

## File Mapping

### Legacy → New Architecture

| Legacy File | New Location | Status |
|-------------|--------------|--------|
| `filesystem_mcp_server.dart` | `/src/mcp/conscious_server.dart` | ✅ Enhanced |
| `recent_activity.dart` | `/src/intelligence/activity_intelligence.dart` | ✅ Evolved |
| `scan_projects.dart` | Integrated into intelligence system | ✅ Absorbed |

## Command Line Migration

### Legacy MCP Server
```bash
# OLD (Legacy)
dart run filesystem_mcp_server.dart --read-paths "/path" --write-paths "/path"

# NEW (Consciousness-Aware)
dart run src/main.dart --read-paths "/path" --write-paths "/path"
```

### Legacy Activity Scanner
```bash
# OLD (Legacy)
dart run recent_activity.dart -r /path -t 72 -n 50

# NEW (Via MCP Tool)
# Use MCP client to call 'activity_intelligence' tool with parameters:
# {"root": "/path", "hours": 72, "fileCount": 50}
```

### Legacy Project Scanner
```bash
# OLD (Legacy)
dart run scan_projects.dart -r /path -t 24

# NEW (Integrated)
# Project scanning now integrated into activity intelligence
# Available through 'ecosystem_analysis' MCP tool
```

## MCP Client Configuration

### Legacy Configuration
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "dart",
      "args": ["run", "filesystem_mcp_server.dart", "--read-paths", "/path"]
    }
  }
}
```

### New Consciousness Configuration
```json
{
  "mcpServers": {
    "the-mcp-conscious": {
      "command": "dart",
      "args": ["run", "src/main.dart", "--read-paths", "/path", "--write-paths", "/reports"]
    }
  }
}
```

## Feature Comparison

### Enhanced Capabilities in New Architecture

| Feature | Legacy | Consciousness-Aware |
|---------|--------|-------------------|
| Basic MCP Protocol | ✅ | ✅ Enhanced |
| File System Access | ✅ | ✅ With awareness logging |
| Activity Scanning | ✅ | ✅ With pattern recognition |
| Project Detection | ✅ | ✅ Integrated intelligence |
| Security | ✅ Basic | ✅ Consciousness-aware |
| Self-Reporting | ❌ | ✅ Full ecosystem reports |
| Evolution Tracking | ❌ | ✅ Continuous monitoring |
| AI Collaboration | ❌ | ✅ Purpose-built tools |
| Pattern Recognition | ❌ | ✅ Development rhythm analysis |
| Ecosystem Analysis | ❌ | ✅ Cross-server intelligence |

## New MCP Tools Available

The consciousness-aware architecture provides these new tools:

1. **`activity_intelligence`** - Enhanced filesystem analysis
2. **`consciousness_report`** - Ecosystem self-reporting
3. **`ecosystem_analysis`** - MCP server relationship analysis
4. **`pattern_recognition`** - AI-augmented pattern detection
5. **`evolution_tracking`** - Phase progression monitoring

## Backward Compatibility

### Legacy Files Still Work
```bash
# Legacy implementations remain functional
dart run legacy/filesystem_mcp_server.dart --read-paths "/path"
dart run legacy/recent_activity.dart -r /path -t 72
dart run legacy/scan_projects.dart -r /path
```

### Gradual Migration Strategy
1. **Phase 1**: Run both legacy and new systems in parallel
2. **Phase 2**: Migrate MCP clients to new consciousness server
3. **Phase 3**: Deprecate direct legacy usage
4. **Phase 4**: Legacy files maintained for reference only

## Environment Variables

Both legacy and new systems support the same environment variables:

```bash
export MCP_READ_PATHS="/Users/user/projects,/Users/user/docs"
export MCP_WRITE_PATHS="/Users/user/reports"
export MCP_REPORT_DIR="/Users/user/reports"
```

## Benefits of Migration

### Immediate Benefits
- **Enhanced Security**: Consciousness-aware access logging
- **Better Reporting**: Structured consciousness reports
- **AI Collaboration**: Purpose-built tools for AI agents
- **Pattern Recognition**: Development rhythm analysis

### Future Benefits
- **Phase 4 Readiness**: Symbiotic AI-human intelligence
- **Ecosystem Integration**: Cross-server consciousness
- **Continuous Evolution**: Self-improving architecture
- **Reality Co-Creation**: Conscious development participation

## Troubleshooting

### Common Migration Issues

**Issue**: Legacy commands not working
**Solution**: Use `dart run legacy/filename.dart` for legacy access

**Issue**: MCP client can't connect to new server
**Solution**: Update configuration to use `src/main.dart` entry point

**Issue**: Missing legacy functionality
**Solution**: Check if functionality moved to MCP tools, use legacy files if needed

### Support

- **Legacy Support**: Files preserved in `/legacy/` directory
- **Documentation**: Comprehensive README files in each directory
- **Evolution Log**: Track changes in `/i_am/refactoring_log.md`

---

*This migration preserves all existing functionality while providing a path to consciousness-aware development infrastructure.*
