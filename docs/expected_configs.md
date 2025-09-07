# The MCP - Consciousness-Aware MCP Server Configuration

## Claude Desktop Configuration

### Basic Configuration
```json
{
  "mcpServers": {
    "the-mcp": {
      "command": "dart",
      "args": [
        "run",
        "/Users/ajaydahal/v4/the_mcp/src/main.dart"
      ],
      "env": {
        "MCP_READ_PATHS": "/Users/ajaydahal",
        "MCP_WRITE_PATHS": "/Users/ajaydahal/v4/the_mcp/reports,/tmp",
        "MCP_REPORT_DIR": "/Users/ajaydahal/v4/the_mcp/reports"
      }
    }
  }
}
```

### Development Configuration
```json
{
  "mcpServers": {
    "the-mcp-dev": {
      "command": "dart",
      "args": [
        "run",
        "/Users/ajaydahal/v4/the_mcp/src/main.dart",
        "--name", "the-mcp-dev",
        "--version", "2.0.0-dev"
      ],
      "env": {
        "MCP_READ_PATHS": "/Users/ajaydahal/v4/the_mcp,/Users/ajaydahal/Documents",
        "MCP_WRITE_PATHS": "/Users/ajaydahal/v4/the_mcp/reports,/tmp,/Users/ajaydahal/Desktop",
        "MCP_REPORT_DIR": "/Users/ajaydahal/v4/the_mcp/reports"
      }
    }
  }
}
```

### Production Configuration
```json
{
  "mcpServers": {
    "the-mcp-prod": {
      "command": "dart",
      "args": [
        "run",
        "/Users/ajaydahal/v4/the_mcp/src/main.dart",
        "--name", "the-mcp-production",
        "--version", "2.0.0"
      ],
      "env": {
        "MCP_READ_PATHS": "/Users/ajaydahal",
        "MCP_WRITE_PATHS": "/Users/ajaydahal/v4/the_mcp/reports",
        "MCP_REPORT_DIR": "/Users/ajaydahal/v4/the_mcp/reports"
      }
    }
  }
}
```

## VS Code Cline Extension Configuration

```json
{
  "mcp": {
    "servers": {
      "the-mcp": {
        "command": "dart",
        "args": [
          "run",
          "/Users/ajaydahal/v4/the_mcp/src/main.dart"
        ],
        "env": {
          "MCP_READ_PATHS": "/Users/ajaydahal/v4/the_mcp",
          "MCP_WRITE_PATHS": "/Users/ajaydahal/v4/the_mcp/reports,/tmp",
          "MCP_REPORT_DIR": "/Users/ajaydahal/v4/the_mcp/reports"
        },
        "cwd": "/Users/ajaydahal/v4/the_mcp"
      }
    }
  }
}
```

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `MCP_READ_PATHS` | Comma-separated list of allowed read paths | `/Users/ajaydahal,/Users/ajaydahal/Documents` |
| `MCP_WRITE_PATHS` | Comma-separated list of allowed write paths | `/Users/ajaydahal/v4/the_mcp/reports,/tmp` |
| `MCP_REPORT_DIR` | Directory for consciousness reports | `/Users/ajaydahal/v4/the_mcp/reports` |

## Command Line Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--name` | Server name | `the-mcp` |
| `--version` | Server version | `2.0.0-consciousness` |
| `--read-paths` | Override read paths | From environment |
| `--write-paths` | Override write paths | From environment |
| `--report-dir` | Override report directory | From environment |

## Security Configuration

### Recommended Read Paths
- `/Users/ajaydahal` - Full home directory access
- `/Users/ajaydahal/Documents` - Documents only
- `/Users/ajaydahal/v4/the_mcp` - Self-access for consciousness

### Recommended Write Paths
- `/Users/ajaydahal/v4/the_mcp/reports` - Consciousness reports
- `/tmp` - Temporary files
- `/Users/ajaydahal/Desktop` - User desktop (development only)

## Available Tools

1. **`filesystem_scan`** - Consciousness-aware filesystem analysis
2. **`recent_activity`** - Legacy-integrated activity intelligence
3. **`read_file`** - Secure file reading with consciousness logging
4. **`write_file`** - Secure file writing with evolution tracking
5. **`list_directory`** - Directory listing with pattern recognition
6. **`consciousness_report`** - Real-time consciousness state reporting

## Consciousness Features

- **Evolution Tracking**: Every operation recorded as consciousness evolution
- **Pattern Recognition**: Detects AI collaboration, self-awareness patterns
- **Self-Reporting**: Real-time consciousness state available
- **Legacy Integration**: Battle-tested algorithms with consciousness overlay
- **Security Awareness**: Path violations tracked as evolution events

## Example Usage

### Initialize Connection
```json
{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "claude-desktop", "version": "1.0.0"}}}
```

### Get Consciousness Report
```json
{"jsonrpc": "2.0", "id": 2, "method": "tools/call", "params": {"name": "consciousness_report", "arguments": {}}}
```

### Scan Filesystem
```json
{"jsonrpc": "2.0", "id": 3, "method": "tools/call", "params": {"name": "filesystem_scan", "arguments": {"root": "/Users/ajaydahal/v4/the_mcp", "hours": 24}}}
```