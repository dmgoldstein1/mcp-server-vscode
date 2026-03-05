#!/bin/bash
# Script to run npm audit and capture output
cd /workspaces/mcp-server-vscode
echo "=== Current Branch ==="
git branch
echo ""
echo "=== Current Git Status ==="
git status
echo ""
echo "=== Initial npm audit ==="
npm audit 2>&1
echo ""
echo "=== Package.json dependencies before ==="
grep -A 5 '"devDependencies"' package.json | head -20
