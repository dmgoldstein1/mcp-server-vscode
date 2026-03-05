# MCP Server for VS Code

A VS Code extension that provides a Model Context Protocol (MCP) server, enabling AI assistants to interact with your VS Code environment for language intelligence, debugging, and code execution.

## Features

- **Language Intelligence**: Access VS Code's language server features including:

  - Go to definition
  - Find references
  - Diagnostics (errors and warnings)
  - Symbol search
  - Call hierarchy

- **Debugging Support**: Control VS Code's debugger programmatically:

  - Start/stop debug sessions
  - Set and manage breakpoints
  - Step through code (into/over/out)
  - Inspect variables and call stacks
  - Evaluate expressions in debug context

## Installation

### Alpha Testing

**Step 1: Install VS Code Extension**

Download the `.vsix` file from [Releases](https://github.com/malvex/mcp-server-vscode/releases) and install:
- In VS Code: Extensions → `...` menu → Install from VSIX
- Or via command line: `code --install-extension mcp-server-vscode-*.vsix`

**Step 2: Configure Claude Desktop**

The MCP server runs directly from GitHub using npx. Add this to your Claude config:

- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "vscode": {
      "command": "npx",
      "args": ["github:malvex/mcp-server-vscode"]
    }
  }
}
```

**Step 3: Restart Claude Desktop**

That's it! The VS Code tools are now available in Claude.

### Configure Claude Code (CLI)

For Claude Code users, run this one-liner:

```bash
claude mcp add-json vscode '{"type":"stdio","command":"npx","args":["github:malvex/mcp-server-vscode"]}' -s user
```

## Usage

Once installed, the extension shows the MCP server status in the VS Code status bar (bottom right).

**To start the MCP server**: Click on "VS Code MCP: Stopped" in the status bar. It will change to "VS Code MCP: 8991" when running.

The status bar indicates:
- **VS Code MCP: 8991** - Server is running on port 8991
- **VS Code MCP: Stopped** - Server is not running

Click the status bar item to toggle the server on/off.

### How It Works

```
┌─────────────┐     stdio      ┌──────────────────┐     HTTP      ┌─────────────┐
│   Claude    │ ◄────────────► │  MCP Standalone  │ ◄───────────► │   VS Code   │
│   Desktop   │                │      Server      │    :8991      │  Extension  │
└─────────────┘                └──────────────────┘               └─────────────┘
```

1. **VS Code Extension** provides an HTTP API on port 8991
2. **MCP Standalone Server** acts as a bridge, converting stdio ↔ HTTP
3. **Claude Desktop** communicates with the standalone server via stdio

### Troubleshooting

If Claude can't connect to VS Code:

1. **Check VS Code is running** with the extension active
2. **Check the status bar** shows "VS Code MCP: 8991"
3. **Test the MCP server**: Run `npx github:malvex/mcp-server-vscode` in terminal
4. **Check firewall** isn't blocking localhost:8991
5. **Try manually starting** the MCP server in VS Code (Cmd/Ctrl+Shift+P → "Start MCP Server")

### Available Tools

The extension provides 25 tools organized into three main categories:

#### Language Intelligence Tools (7 tools)

| Tool | Description | Main Parameters | Example |
|------|-------------|-----------------|---------|
| **hover** | Get hover information (type info, documentation) for a symbol by name | `symbol` (required), `uri` (optional), `format` (optional) | `hover({ symbol: "calculateSum" })` |
| **definition** | Find where a symbol is defined. Instantly jumps to declarations | `symbol` (required), `format` (optional) | `definition({ symbol: "Calculator" })` |
| **references** | Find all references to a symbol. Superior to grep - finds semantic references | `symbol` (required), `includeDeclaration` (optional), `format` (optional) | `references({ symbol: "process" })` |
| **callHierarchy** | Analyze what calls a function or what a function calls | `symbol` (required), `direction` (required: 'incoming'\|'outgoing'\|'both'), `uri` (optional), `format` (optional) | `callHierarchy({ symbol: "initialize", direction: "incoming" })` |
| **symbolSearch** | Search for symbols (classes, functions, variables) across the workspace | `query` (required), `kind` (optional), `format` (optional) | `symbolSearch({ query: "Controller", kind: "class" })` |
| **workspaceSymbols** | Get a complete map of all symbols in the workspace | `includeDetails` (optional), `filePattern` (optional), `maxFiles` (optional), `format` (optional) | `workspaceSymbols({ filePattern: "**/*.ts" })` |
| **diagnostics** | Get all errors and warnings for a file or workspace | `uri` (optional), `format` (optional) | `diagnostics({})` |

#### Refactoring Tools (1 tool)

| Tool | Description | Main Parameters | Example |
|------|-------------|-----------------|---------|
| **refactor_rename** | Rename a symbol across all files. Automatically updates all references and imports | `symbol` (required), `newName` (required), `uri` (optional), `format` (optional) | `refactor_rename({ symbol: "OldName", newName: "NewName" })` |

#### Debug Tools (17 tools)

##### Breakpoint Management

| Tool | Description | Main Parameters | Example |
|------|-------------|-----------------|---------|
| **debug_setBreakpoint** | Set breakpoints by symbol name or file/line with optional conditions | `symbol` OR (`file` AND `line`), `condition` (optional), `hitCondition` (optional), `logMessage` (optional), `format` (optional) | `debug_setBreakpoint({ symbol: "processData", condition: "items.length > 100" })` |
| **debug_toggleBreakpoint** | Toggle a breakpoint on/off at a specific location | `symbol` OR (`file` AND `line`), `format` (optional) | `debug_toggleBreakpoint({ file: "app.js", line: 25 })` |
| **debug_listBreakpoints** | List all breakpoints in the workspace | `format` (optional) | `debug_listBreakpoints({})` |
| **debug_clearBreakpoints** | Clear all breakpoints from the workspace | `format` (optional) | `debug_clearBreakpoints({})` |

##### Session Management

| Tool | Description | Main Parameters | Example |
|------|-------------|-----------------|---------|
| **debug_status** | Get current debug session status and active threads | `format` (optional) | `debug_status({})` |
| **debug_listConfigurations** | List available debug configurations from launch.json | `format` (optional) | `debug_listConfigurations({})` |
| **debug_startSession** | Start a debug session using a configuration | `configuration` (optional), `format` (optional) | `debug_startSession({ configuration: "Launch Program" })` |
| **debug_stopSession** | Stop the active debug session | `format` (optional) | `debug_stopSession({})` |

##### Runtime Control

| Tool | Description | Main Parameters | Example |
|------|-------------|-----------------|---------|
| **debug_pauseExecution** | Pause the running program | `threadId` (optional), `format` (optional) | `debug_pauseExecution({})` |
| **debug_continueExecution** | Continue execution from current breakpoint | `threadId` (optional), `allThreads` (optional), `format` (optional) | `debug_continueExecution({})` |
| **debug_stepOver** | Step over the current line of code | `threadId` (optional), `format` (optional) | `debug_stepOver({})` |
| **debug_stepInto** | Step into the function call at current line | `threadId` (optional), `format` (optional) | `debug_stepInto({})` |
| **debug_stepOut** | Step out of the current function | `threadId` (optional), `format` (optional) | `debug_stepOut({})` |

##### Inspection and Evaluation

| Tool | Description | Main Parameters | Example |
|------|-------------|-----------------|---------|
| **debug_getCallStack** | Get the current call stack with source locations | `threadId` (optional), `startFrame` (optional), `levels` (optional), `format` (optional) | `debug_getCallStack({ levels: 10 })` |
| **debug_inspectVariables** | Inspect variables in the current scope during debugging | `threadId` (optional), `frameId` (optional), `scope` (optional: 'all'\|'locals'\|'globals'\|'closure'), `filter` (optional), `format` (optional) | `debug_inspectVariables({ scope: "locals" })` |
| **debug_evaluateExpression** | Evaluate an expression in the debug context | `expression` (required), `frameId` (optional), `context` (optional), `format` (optional) | `debug_evaluateExpression({ expression: "user.permissions" })` |
| **debug_getOutput** | Get debug console output | `category` (optional), `filter` (optional), `limit` (optional), `format` (optional) | `debug_getOutput({})` |

### Tool Features

All tools support:

- **Compact format** - Optimized for AI token efficiency
- **Detailed format** - Full data for complex analysis
- **Symbol-based navigation** - Work with names instead of file/line numbers
- **Workspace-wide operations** - Not limited to single files
- **Language server integration** - Accurate semantic understanding

### Usage Examples for AI Assistants

When connected via MCP, AI assistants can use these tools to help users with development tasks:

#### Finding and Understanding Code

```
User: "What does the handleRequest function do?"
AI uses: hover({ symbol: "handleRequest" })
→ Gets type signature and documentation without reading entire files

User: "Where is the DatabaseConnection class defined?"
AI uses: definition({ symbol: "DatabaseConnection" })
→ Instantly finds the file and line where it's declared

User: "Show me all places where processPayment is called"
AI uses: callHierarchy({ symbol: "processPayment", direction: "incoming" })
→ Gets complete list of callers with their locations
```

#### Refactoring

```
User: "Rename the oldMethodName method to newMethodName everywhere"
AI uses: refactor_rename({ symbol: "oldMethodName", newName: "newMethodName" })
→ Safely renames across all files, updating imports and references
```

#### Debugging

```
User: "Help me debug why the server crashes"
AI uses: debug_listConfigurations({})
→ Shows available debug configurations

AI uses: debug_startSession({ configuration: "Debug Server" })
→ Starts the debug session

User: "Set a breakpoint where errors are handled"
AI uses: debug_setBreakpoint({ symbol: "handleError" })
→ Sets breakpoint on the function

User: "What's the value of the user object here?"
AI uses: debug_inspectVariables({ scope: "locals", filter: "user" })
→ Shows current value of user variable in debug context

User: "Why is this condition true?"
AI uses: debug_evaluateExpression({ expression: "users.length > 0 && isActive" })
→ Evaluates the expression in current debug scope
```

## N|Solid Runtime Integration

This project supports running on the **N|Solid runtime** for enhanced observability and monitoring. N|Solid is an enhanced, hardened fork of Node.js that provides zero-code instrumentation and built-in telemetry.

### What is N|Solid?

N|Solid provides:

- **Zero-code instrumentation** - No changes to application code required
- **Built-in observability** - CPU profiling, heap snapshots, event loop metrics
- **OpenTelemetry integration** - Standards-based telemetry export
- **Security monitoring** - Vulnerability detection in dependencies
- **Drop-in replacement** - The `nsolid` command works exactly like `node`

### Installing N|Solid

#### Linux

```bash
# For Node.js 24.x (Krypton LTS)
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt-get install nsolid -y

# For Node.js 22.x (Jod LTS)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install nsolid -y
```

#### macOS

```bash
# Using Homebrew
brew install nsolid
```

#### Docker

```bash
# Pull official N|Solid image
docker pull nodesource/nsolid:krypton-latest  # Node.js 24.x
docker pull nodesource/nsolid:jod-latest      # Node.js 22.x
```

### Running with N|Solid

#### Quick Start

Use the included start script for easy setup:

```bash
# Run with automatic N|Solid detection and configuration
npm run start:nsolid
```

The script will:
- Check if N|Solid is installed
- Display version information
- Auto-detect OTLP collector if available
- Start the server with optimal settings

#### Basic Usage

Replace `node` with `nsolid`:

```bash
# Before
npm run start:mcp:node

# After
npm run start:mcp
```

#### With Environment Variables

```bash
# Set application name and enable tracing
export NSOLID_APPNAME="mcp-server-vscode"
export NSOLID_TRACING_ENABLED=1
export NSOLID_OTLP=otlp
export NSOLID_OTLP_CONFIG='{"url":"http://localhost:4318/v1/traces","protocol":"http"}'

# Run with N|Solid
npm run start:mcp
```

### Docker Deployment with N|Solid

The included `Dockerfile` uses the N|Solid runtime by default:

```bash
# Build the Docker image
docker build -t mcp-server-vscode .

# Run the container
docker run -p 8991:8991 mcp-server-vscode
```

### Monitoring Stack

The included `docker-compose.yml` provides a complete observability stack:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f mcp-server-vscode

# Stop services
docker-compose down
```

**Services included:**

| Service | Port | Purpose |
|---------|------|---------|
| mcp-server-vscode | 8991 | MCP Server |
| otel-collector | 4317, 4318 | Telemetry collection |
| clickhouse | 8123, 9000 | Metrics storage |
| nsolid-api | 3001 | Backend API |
| nsolid-ui | 3002 | Web dashboard |

### Verification

After starting with N|Solid:

1. Check N|Solid version: `nsolid -vv`
2. Open N|Solid UI: http://localhost:3002
3. Verify application appears in the dashboard
4. Check metrics and traces are flowing

### Configuration

N|Solid can be configured via:

1. **package.json** - Already configured in this project
2. **Environment variables** - Override package.json settings
3. **JavaScript API** - For programmatic control

See the `nsolid` section in `package.json` for default configuration.

## Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/malvex/mcp-server-vscode.git
cd mcp-server-vscode

# Install dependencies
npm install

# Build everything
npm run compile
npm run package

# Package the VS Code extension
npx vsce package
```

### Testing Local Changes

To test your local development version:

1. **VS Code Extension**: Press F5 in VS Code to launch Extension Development Host
2. **MCP Server**: Update Claude config to use local path:

```json
{
  "mcpServers": {
    "vscode": {
      "command": "node",
      "args": ["/path/to/mcp-server-vscode/out/mcp/standalone-server.js"]
    }
  }
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
