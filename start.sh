#!/bin/bash
# ============================================================
# WhatsApp MCP — Start Services
# Works with both Docker and Podman (open source).
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ----------------------------------------------------------
# Detect container runtime
# ----------------------------------------------------------
if command -v podman-compose &>/dev/null && podman machine list 2>/dev/null | grep -qi "running"; then
    COMPOSE="podman-compose"
    RUNTIME="podman"
elif command -v podman-compose &>/dev/null; then
    COMPOSE="podman-compose"
    RUNTIME="podman"
    echo "[!] Podman machine not running. Starting..."
    podman machine start || true
elif command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
    COMPOSE="docker compose"
    RUNTIME="docker"
else
    echo "ERROR: No container runtime found."
    echo "Install Podman:  brew install podman podman-compose"
    echo "            or:  pip install podman-compose"
    exit 1
fi

echo "Using: $RUNTIME ($COMPOSE)"
echo ""

# ----------------------------------------------------------
# Build images
# ----------------------------------------------------------
echo "[1/4] Building images..."
$COMPOSE build
echo ""

# ----------------------------------------------------------
# Start bridge first
# ----------------------------------------------------------
echo "[2/4] Starting WhatsApp bridge..."
$COMPOSE up -d whatsapp-bridge
echo ""

# ----------------------------------------------------------
# Wait for bridge health
# ----------------------------------------------------------
echo "[3/4] Waiting for bridge to be healthy..."
MAX_WAIT=60
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    if $RUNTIME exec whatsapp-mcp_whatsapp-bridge_1 wget -qO /dev/null http://localhost:8080/api/health 2>/dev/null; then
        echo "  Bridge is healthy (${WAITED}s)"
        break
    fi
    sleep 2
    WAITED=$((WAITED + 2))
    printf "  waiting... (%ds/%ds)\r" "$WAITED" "$MAX_WAIT"
done

if [ $WAITED -ge $MAX_WAIT ]; then
    echo ""
    echo "  WARNING: Bridge did not become healthy in ${MAX_WAIT}s."
    echo "  Starting MCP server anyway (it will retry via restart policy)."
fi
echo ""

# ----------------------------------------------------------
# Start MCP server
# ----------------------------------------------------------
echo "[4/4] Starting MCP server..."
$COMPOSE up -d whatsapp-mcp

# podman-compose may leave MCP in "Created" state — force start
if [ "$RUNTIME" = "podman" ]; then
    sleep 1
    MCP_CONTAINER=$($COMPOSE ps 2>/dev/null | grep whatsapp-mcp | grep -i "created" | awk '{print $1}')
    if [ -n "$MCP_CONTAINER" ]; then
        podman start "$MCP_CONTAINER"
    fi
fi

sleep 2

# ----------------------------------------------------------
# Verify
# ----------------------------------------------------------
echo ""
echo "=========================================="
echo "  Status"
echo "=========================================="
$COMPOSE ps
echo ""

# Quick SSE check
if curl -sf --max-time 3 http://127.0.0.1:8081/sse >/dev/null 2>&1; then
    echo "  MCP SSE endpoint: http://localhost:8081/sse  [OK]"
else
    echo "  MCP SSE endpoint: http://localhost:8081/sse  [waiting...]"
    echo "  Check logs: $COMPOSE logs whatsapp-mcp"
fi

BRIDGE_STATUS=$($RUNTIME exec whatsapp-mcp_whatsapp-bridge_1 wget -qO- http://localhost:8080/api/health 2>/dev/null || echo '{"connected":false}')
if echo "$BRIDGE_STATUS" | grep -q '"connected":true'; then
    echo "  WhatsApp: connected"
else
    echo "  WhatsApp: not paired — scan the QR code"
    echo ""
    echo "  To see the QR code:"
    echo "    $COMPOSE logs -f whatsapp-bridge"
    echo ""
    echo "  Then on your phone:"
    echo "    WhatsApp > Settings > Linked Devices > Link a Device"
fi

echo ""
echo "=========================================="
echo "  Commands"
echo "=========================================="
echo "  $COMPOSE logs -f whatsapp-bridge   # QR code / bridge logs"
echo "  $COMPOSE logs -f whatsapp-mcp      # MCP server logs"
echo "  $COMPOSE ps                        # container status"
echo "  $COMPOSE down                      # stop everything"
echo ""
