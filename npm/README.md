# Reqable MCP Server

[![npm version](https://img.shields.io/npm/v/reqable-mcp-server.svg)](https://www.npmjs.com/package/reqable-mcp-server)

**Reqable MCP Server** is a command-line tool that connects your AI assistant to [Reqable](https://reqable.com) via the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/).

It exposes Reqable's APIs as MCP tools, enabling AI models to interact with Reqable's debugging and traffic management features.

## Installation

```bash
npm install -g reqable-mcp-server
```

> **Note:** npm automatically downloads only the native binary matching your platform — no need to worry about other platform binaries.

## Usage

```bash
reqable-mcp-server --help
```

### Options

| Option | Alias | Description | Default |
|--------|-------|-------------|---------|
| `--host` | `-h` | Reqable app host | `127.0.0.1` |
| `--port` | `-p` | Reqable app port | `9000` |
| `--scope` | `-s` | Tool scope (`minimal`, `full`) | `minimal` |

### Example

```bash
reqable-mcp-server --host 127.0.0.1 --port 9000 --scope full
```

## MCP Configuration

Add to your AI assistant's MCP configuration (e.g., Claude Desktop, VS Code Copilot):

```json
{
  "mcpServers": {
    "reqable-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "reqable-mcp-server"
      ]
    }
  }
}
```

Or with a local installation:

```json
{
  "mcpServers": {
    "reqable-mcp": {
      "command": "reqable-mcp-server",
      "args": []
    }
  }
}
```

## Supported Platforms

| Platform | Architecture | Status |
|----------|-------------|--------|
| macOS | ARM64 (Apple Silicon) | ✅ |
| macOS | x64 (Intel) | ✅ |
| Linux | x64 | ✅ |
| Windows | x64 | ✅ |

## How It Works

This package uses **platform-specific optional dependencies** — the same pattern used by esbuild, swc, and other popular tools. When you `npm install`, npm automatically downloads only the native binary for your platform:

| Platform Package | OS | CPU |
|-----------------|----|----|
| `reqable-mcp-server-darwin-arm64` | macOS | arm64 (Apple Silicon) |
| `reqable-mcp-server-darwin-x64` | macOS | x64 (Intel) |
| `reqable-mcp-server-linux-x64` | Linux | x64 |
| `reqable-mcp-server-win32-x64` | Windows | x64 |

The Node.js entry script (`bin/mcp-server.js`) locates the binary from the matching platform package and spawns it. This approach provides:

- **Performance:** Native execution speed via Dart AOT compilation
- **Efficient installs:** Only ~6MB download (single platform binary), not ~25MB (all platforms)
- **Zero dependencies:** No Dart SDK or runtime required at install time

## License

MIT
