#!/usr/bin/env node

/**
 * Reqable MCP Server - Node.js wrapper
 *
 * Detects the current platform and architecture, then spawns the
 * corresponding Dart AOT-compiled native binary.
 *
 * Supported platforms:
 *   - darwin-arm64  (macOS Apple Silicon)
 *   - darwin-x64    (macOS Intel)
 *   - linux-x64     (Linux x86_64)
 *   - win32-x64     (Windows x86_64)
 */

const { spawn } = require('child_process');
const path = require('path');
const os = require('os');
const fs = require('fs');

function getPlatformTriple() {
  const platform = os.platform();   // 'darwin', 'linux', 'win32'
  const arch = os.arch();           // 'x64', 'arm64'

  // Normalize architecture names
  const archMap = {
    x64: 'x64',
    arm64: 'arm64',
  };
  const normalizedArch = archMap[arch] || arch;

  return `${platform}-${normalizedArch}`;
}

function getBinaryPath() {
  const triple = getPlatformTriple();
  const binaryName = process.platform === 'win32' ? 'mcp-server.exe' : 'mcp-server';
  const packageName = `reqable-mcp-server-${triple}`;

  // Resolve from the platform-specific npm package (production)
  try {
    const packageDir = path.dirname(require.resolve(`${packageName}/package.json`));
    const binaryPath = path.join(packageDir, binaryName);
    if (fs.existsSync(binaryPath)) {
      return binaryPath;
    }
  } catch (e) {
    // Platform package not installed, try fallbacks
  }

  // Fallback: check sibling platform packages
  const fallbackTriples = ['darwin-arm64', 'darwin-x64', 'linux-x64', 'win32-x64'];
  for (const fallback of fallbackTriples) {
    try {
      const fbDir = path.dirname(require.resolve(`reqable-mcp-server-${fallback}/package.json`));
      const fbPath = path.join(fbDir, binaryName);
      if (fs.existsSync(fbPath)) {
        console.error(`Warning: No binary for ${triple}, using fallback: ${fallback}`);
        return fbPath;
      }
    } catch (e) { /* ignore */ }
  }

  // Local dev fallback (binary in platform/ directory)
  const localPath = path.join(__dirname, '..', 'platform', triple, binaryName);
  if (fs.existsSync(localPath)) {
    return localPath;
  }

  console.error(`Error: No prebuilt binary found for platform: ${triple}`);
  console.error(`Expected platform package: ${packageName}`);
  process.exit(1);
}

const binaryPath = getBinaryPath();

// Make sure the binary is executable (Unix systems)
if (process.platform !== 'win32') {
  try {
    fs.chmodSync(binaryPath, 0o755);
  } catch (e) {
    // Ignore permission errors
  }
}

// Spawn the binary with the same arguments passed to this script
const child = spawn(binaryPath, process.argv.slice(2), {
  stdio: 'inherit',
  env: process.env,
});

child.on('error', (err) => {
  console.error(`Failed to start Reqable MCP Server: ${err.message}`);
  process.exit(1);
});

child.on('exit', (code, signal) => {
  if (signal) {
    process.exitCode = 128 + (signal === 'SIGTERM' ? 15 : signal === 'SIGINT' ? 2 : 1);
    return;
  }
  process.exitCode = code || 0;
});
