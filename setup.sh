#!/bin/bash
# ============================================================
# WhatsApp MCP Server — Docker Setup
# One-shot script to build, start, and configure everything.
# ============================================================
set -e

INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "  WhatsApp MCP Server — Docker Setup"
echo "=========================================="
echo ""

# ----------------------------------------------------------
# Step 1: Check prerequisites
# ----------------------------------------------------------
echo "[1/4] Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo "  ERROR: Docker is not installed."
    echo "  Install Docker Desktop from: https://www.docker.com/products/docker-desktop/"
    exit 1
fi
echo "  Docker $(docker --version | awk '{print $3}' | tr -d ',')"

if ! docker info &> /dev/null 2>&1; then
    echo "  ERROR: Docker daemon is not running. Start Docker Desktop and try again."
    exit 1
fi
echo "  Docker daemon is running"
echo ""

# ----------------------------------------------------------
# Step 2: Build and start containers
# ----------------------------------------------------------
echo "[2/4] Building and starting containers..."
echo "  (first build may take a few minutes)"
echo ""
cd "$INSTALL_DIR"
docker compose build
docker compose up -d
echo ""
echo "  Containers started"
echo ""

# ----------------------------------------------------------
# Step 3: Configure Claude Desktop (if on macOS)
# ----------------------------------------------------------
echo "[3/4] Claude Desktop configuration..."

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

# ----------------------------------------------------------
# Step 4: Show QR code instructions
# ----------------------------------------------------------
echo "[4/4] Link your WhatsApp account..."
echo ""
echo "  Run this to see the QR code:"
echo ""
echo "    docker compose logs -f whatsapp-bridge"
echo ""
echo "  Then on your phone:"
echo "    WhatsApp -> Settings -> Linked Devices -> Link a Device"
echo ""
echo "=========================================="
echo "  Setup complete!"
echo "=========================================="
echo ""
echo "  Useful commands:"
echo ""
echo "    docker compose logs -f whatsapp-bridge   # QR code / bridge logs"
echo "    docker compose logs -f whatsapp-mcp      # MCP server logs"
echo "    docker compose ps                        # container status"
echo "    docker compose down                      # stop everything"
echo "    docker compose restart                   # restart services"
echo ""
