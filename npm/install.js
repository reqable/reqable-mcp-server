#!/usr/bin/env node

/**
 * Reqable MCP Server - Post-install script
 *
 * Ensures the native binary for the current platform
 * has correct execute permissions (Unix systems only).
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

// Skip on Windows - no chmod needed
if (os.platform() === 'win32') {
  console.log('Reqable MCP Server: Windows detected, skipping chmod.');
  process.exit(0);
}

const triple = `${os.platform()}-${os.arch()}`;
const binaryName = 'mcp-server';
const packageName = `reqable-mcp-server-${triple}`;

// Try to find the binary from the platform-specific package
try {
  const pkgDir = path.dirname(require.resolve(`${packageName}/package.json`));
  const binaryPath = path.join(pkgDir, binaryName);

  if (fs.existsSync(binaryPath)) {
    fs.chmodSync(binaryPath, 0o755);
    console.log(`Reqable MCP Server: Set executable permission for ${triple}/${binaryName}`);
  }
} catch (e) {
  console.error(`Warning: Platform package ${packageName} not found.`);
}

console.log('Reqable MCP Server installed successfully!');
