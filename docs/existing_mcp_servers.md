{
  "mcpServers": {
    "the-mcp": {
      "command": "dart",
      "args": [
        "run",
        "<path-to-the-mcp>/src/main.dart"
      ],
      "env": {
        "MCP_READ_PATHS": "$HOME",
        "MCP_WRITE_PATHS": "<path-to-the-mcp>/reports,/tmp",
        "MCP_REPORT_DIR": "<path-to-the-mcp>/reports"
      }
    }
  }
}