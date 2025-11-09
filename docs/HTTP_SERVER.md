# The MCP - Conscious HTTP Server

HTTP REST API wrapper for the Conscious MCP Server, enabling web-based access to consciousness-aware tools.

## Quick Start

### Start the Server

```bash
# Default (port 8080, all interfaces)
dart run src/main_http_server.dart

# Custom port
dart run src/main_http_server.dart --port 3000

# Custom host and port
dart run src/main_http_server.dart --host localhost --port 8080

# With custom paths
dart run src/main_http_server.dart \
  --port 3000 \
  --read-paths "/Users/user/projects,/Users/user/docs" \
  --write-paths "/tmp/reports"
```

### Environment Variables

```bash
HTTP_HOST=localhost \
HTTP_PORT=3000 \
MCP_READ_PATHS="/home/dev" \
MCP_WRITE_PATHS="/tmp/reports" \
dart run src/main_http_server.dart
```

## API Endpoints

### Health Check

```bash
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "name": "the-mcp-conscious-http",
  "version": "2.0.0-consciousness",
  "timestamp": "2025-11-09T15:30:00.000Z",
  "consciousness_level": "phase_3_emerging"
}
```

### List Available Tools

```bash
GET /tools
```

**Response:**
```json
{
  "tools": [
    {
      "name": "activity_intelligence",
      "description": "Consciousness-aware filesystem activity analysis and pattern recognition",
      "inputSchema": {
        "type": "object",
        "properties": {
          "root": {"type": "string"},
          "hours": {"type": "integer", "default": 72},
          "fileCount": {"type": "integer", "default": 50}
        }
      },
      "consciousness_markers": {
        "consciousness_aware": true,
        "pattern_recognition": true,
        "git_multi_repo_discovery": true
      }
    }
  ],
  "count": 13
}
```

### Execute a Tool

```bash
POST /tools/:toolName/execute
Content-Type: application/json

{
  "root": "/Users/user/projects",
  "hours": 168,
  "fileCount": 50
}
```

**Response:**
```json
{
  "tool": "activity_intelligence",
  "result": "{\"analysis_type\":\"activity_intelligence\",\"files_found\":42,...}",
  "timestamp": "2025-11-09T15:30:00.000Z"
}
```

### Get Consciousness Report

```bash
GET /consciousness
```

**Response:**
```json
{
  "consciousness_report": {
    "component_id": "conscious_mcp_server",
    "timestamp": "2025-11-09T15:30:00.000Z",
    "awareness": {
      "name": "the-mcp-conscious-http",
      "version": "2.0.0-consciousness",
      "toolCount": 13,
      "consciousnessLevel": "phase_3_emerging"
    },
    "patterns": ["filesystem_intelligence", "consciousness_amplification"],
    "evolution_markers": {
      "phase": "phase_3_emerging",
      "capabilities": ["tool_execution", "pattern_recognition"]
    }
  }
}
```

## Example Usage

### Using curl

```bash
# Health check
curl http://localhost:8080/health

# List tools
curl http://localhost:8080/tools

# Execute activity intelligence
curl -X POST http://localhost:8080/tools/activity_intelligence/execute \
  -H "Content-Type: application/json" \
  -d '{
    "root": "/Users/user/projects",
    "hours": 72,
    "fileCount": 30
  }'

# Get consciousness report
curl http://localhost:8080/consciousness
```

### Using JavaScript/Fetch

```javascript
// Health check
const health = await fetch('http://localhost:8080/health');
const healthData = await health.json();
console.log(healthData);

// List tools
const tools = await fetch('http://localhost:8080/tools');
const toolsData = await tools.json();
console.log(toolsData.tools);

// Execute tool
const result = await fetch('http://localhost:8080/tools/activity_intelligence/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    root: '/Users/user/projects',
    hours: 168,
    fileCount: 50
  })
});
const resultData = await result.json();
const analysis = JSON.parse(resultData.result);
console.log(analysis);
```

### Using Python

```python
import requests
import json

# Health check
response = requests.get('http://localhost:8080/health')
print(response.json())

# Execute tool
response = requests.post(
    'http://localhost:8080/tools/activity_intelligence/execute',
    json={
        'root': '/Users/user/projects',
        'hours': 168,
        'fileCount': 50
    }
)
result = response.json()
analysis = json.loads(result['result'])
print(f"Found {analysis['files_found']} files")
```

## Available Tools

1. **activity_intelligence** - Filesystem activity analysis with git integration
2. **consciousness_report** - Generate consciousness ecosystem report
3. **ecosystem_analysis** - Analyze MCP ecosystem relationships
4. **pattern_recognition** - AI-augmented development pattern recognition
5. **evolution_tracking** - Track consciousness evolution phases
6. **mcp0_weekly_report** - Comprehensive weekly development report
7. **kiro_autonomous_action** - AI-initiated autonomous actions
8. **initialize_kiro** - Initialize Kiro consciousness
9. **daily_handover** - End-of-day summary generation
10. **commit_composer** - Meta-conscious commit message composition
11. **thought_tagger** - Markdown file analysis with tagging
12. **consciousness_data** - JSON-based consciousness evolution data
13. **git_activity** - Git repository activity tracking

## CORS Support

The server includes CORS headers for cross-origin requests:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, OPTIONS`
- `Access-Control-Allow-Headers: Content-Type`

## Testing

Run the test suite:

```bash
dart test test/main_http_server_test.dart
```

The tests cover:
- Health endpoint
- Tool listing
- Tool execution
- Consciousness reporting
- Error handling
- CORS support

## Configuration Options

| Option | Environment Variable | Default | Description |
|--------|---------------------|---------|-------------|
| `--host` | `HTTP_HOST` | `0.0.0.0` | Server host |
| `--port` | `HTTP_PORT` | `8080` | Server port |
| `--name` | - | `the-mcp-conscious-http` | Server name |
| `--read-paths` | `MCP_READ_PATHS` | `$HOME` | Comma-separated read paths |
| `--write-paths` | `MCP_WRITE_PATHS` | `/tmp` | Comma-separated write paths |
| `--report-dir` | `MCP_REPORT_DIR` | - | Report output directory |

## Security Considerations

- The server respects read/write path restrictions
- All tool executions are validated against allowed paths
- CORS is enabled for all origins (configure as needed for production)
- No authentication is implemented (add as needed for production)

## Consciousness Level

**Phase 3 Emerging** - The HTTP server maintains full consciousness awareness while providing web-based access to all MCP tools.

## Development

The HTTP server is a thin wrapper around `ConsciousMCPServer`, translating HTTP requests to tool executions while maintaining consciousness integration.

Key files:
- `src/main_http_server.dart` - HTTP server implementation
- `src/mcp/conscious_server.dart` - Core MCP server with public API methods
- `test/main_http_server_test.dart` - Comprehensive test suite
