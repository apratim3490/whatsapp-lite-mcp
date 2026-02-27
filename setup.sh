#!/bin/bash
# ============================================================
# WhatsApp MCP Server — First-Time Setup
# Builds containers, starts services, and configures Claude.
# For subsequent starts, use ./start.sh instead.
# ============================================================
set -e

INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "  WhatsApp MCP Server — Setup"
echo "=========================================="
echo ""

# ----------------------------------------------------------
# Step 1: Check prerequisites
# ----------------------------------------------------------
echo "[1/3] Checking prerequisites..."

if command -v podman &>/dev/null; then
    echo "  Podman $(podman --version | awk '{print $NF}')"
    if ! command -v podman-compose &>/dev/null; then
        echo "  Installing podman-compose..."
        pip3 install podman-compose
    fi
elif command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
    echo "  Docker $(docker --version | awk '{print $3}' | tr -d ',')"
else
    echo "  ERROR: No container runtime found."
    echo "  Install Podman:  brew install podman && pip3 install podman-compose"
    exit 1
fi
echo ""

# ----------------------------------------------------------
# Step 2: Build and start services
# ----------------------------------------------------------
echo "[2/3] Building and starting services..."
echo ""
"$INSTALL_DIR/start.sh"
echo ""

# ----------------------------------------------------------
# Step 3: Configure Claude Desktop (if on macOS)
# ----------------------------------------------------------
echo "[3/3] Claude Desktop configuration..."

CLAUDE_CONFIG_FILE="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

if [ -f "$CLAUDE_CONFIG_FILE" ]; then
    echo "  Config already exists at:"
    echo "  $CLAUDE_CONFIG_FILE"
    echo ""
    echo "  Add this to your \"mcpServers\" section:"
    echo ""
    echo '    "whatsapp": {'
    echo '      "url": "http://localhost:8081/sse"'
    echo '    }'
else
    mkdir -p "$(dirname "$CLAUDE_CONFIG_FILE")"
    cat > "$CLAUDE_CONFIG_FILE" <<'EOF'
{
  "mcpServers": {
    "whatsapp": {
      "url": "http://localhost:8081/sse"
    }
  }
}
EOF
    echo "  Claude Desktop config created"
fi
echo ""
echo "=========================================="
echo "  Setup complete!"
echo "=========================================="
echo ""
