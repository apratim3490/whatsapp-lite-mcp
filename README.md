# WhatsApp MCP (Send-Only)

A containerized [Model Context Protocol](https://modelcontextprotocol.io/) server that lets Claude send WhatsApp messages. **Send-only by design** — no ability to read messages, list chats, or access conversation history.

Based on [FelixIsaac/whatsapp-mcp-extended](https://github.com/FelixIsaac/whatsapp-mcp-extended), stripped down to two tools.

## Architecture

```
┌──────────────┐  stdio  ┌───────────┐  SSE   ┌────────────────┐
│ Claude       │◄───────►│ mcp-proxy │◄──────►│ whatsapp-mcp   │
│ Desktop /    │         │ (uvx)     │        │ (Python, :8081) │
│ Cowork       │         └───────────┘        │ Container      │
└──────────────┘                              └───────┬────────┘
                                                      │ internal
                                                      │ network
                                              ┌───────▼────────┐
                                              │ whatsapp-bridge │
                                              │ (Go, whatsmeow) │
                                              │ Container (:8080)│
                                              └────────────────┘
```

| Component | Role | Exposed to host |
|-----------|------|-----------------|
| **whatsapp-bridge** | Go binary using [whatsmeow](https://github.com/tulir/whatsmeow) to talk to WhatsApp Web | No — internal network only |
| **whatsapp-mcp** | Python MCP server (FastMCP) with SSE transport | `127.0.0.1:8081` (localhost only) |
| **mcp-proxy** | Bridges SSE to stdio so Claude Desktop can connect | N/A — runs as a local subprocess |

**Security layers:**
- The Go bridge is **not exposed to the host** — only reachable within the container network
- Only 2 API routes on the bridge: `/api/health` and `/api/send`
- The MCP server exposes only `send_message` and `send_file` tools
- MCP port bound to `127.0.0.1` (not accessible from other machines)

## Tools

| Tool | Description |
|------|-------------|
| `send_message` | Send a text message to a phone number or group JID |
| `send_file` | Send an image, video, or document to a phone number or group JID |

That's it. No read access, no chat listing, no contact search, no group management.

## Quick Start

### Prerequisites

- **Podman** (recommended): `brew install podman && pip3 install podman-compose`
  - Or **Docker** with Docker Compose
- **uv** (for Claude Desktop/Cowork connection): `brew install uv` or `curl -LsSf https://astral.sh/uv/install.sh | sh`

### 1. Clone and start

```bash
git clone https://github.com/apratim3490/whatsapp-lite-mcp.git
cd whatsapp-lite-mcp
./setup.sh
```

For subsequent starts:

```bash
./start.sh
```

### 2. Pair your WhatsApp

Scan the QR code shown in the bridge logs:

```bash
podman-compose logs -f whatsapp-bridge
```

On your phone: **WhatsApp > Settings > Linked Devices > Link a Device**

### 3. Connect to Claude Desktop / Cowork

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "whatsapp": {
      "command": "uvx",
      "args": ["mcp-proxy", "http://127.0.0.1:8081/sse"]
    }
  }
}
```

This uses [`mcp-proxy`](https://pypi.org/project/mcp-proxy/) (installed on-demand via `uvx`) to bridge the container's SSE endpoint to stdio for Claude Desktop. No Node.js required.

Restart Claude Desktop after updating the config.

### 4. Connect to Claude Code

Add to your project or user-level `.claude.json`:

```json
{
  "mcpServers": {
    "whatsapp": {
      "command": "uvx",
      "args": ["mcp-proxy", "http://127.0.0.1:8081/sse"]
    }
  }
}
```

## Container Runtime

The project supports both **Podman** (open source, daemonless) and **Docker**. The `setup.sh` and `start.sh` scripts auto-detect which runtime is available.

| Podman | Docker |
|--------|--------|
| `podman-compose up -d` | `docker compose up -d` |
| `podman-compose logs -f whatsapp-bridge` | `docker compose logs -f whatsapp-bridge` |
| `podman-compose ps` | `docker compose ps` |
| `podman-compose down` | `docker compose down` |

If using Podman, ensure the machine is running first: `podman machine start`

## Troubleshooting

### Containers running but Claude can't connect

1. Verify the MCP endpoint is responding:
   ```bash
   curl -s http://127.0.0.1:8081/sse --max-time 3
   ```
   You should see `event: endpoint` in the output.

2. Verify `uvx` is available:
   ```bash
   uvx mcp-proxy --help
   ```

3. Restart Claude Desktop after changing the config.

### Bridge shows "unhealthy"

The bridge may report `unhealthy` until WhatsApp is paired. This is normal — scan the QR code first.

### Client Outdated (405)

```bash
cd whatsapp-bridge
go get -u go.mau.fi/whatsmeow@latest
go mod tidy
cd ..
podman-compose build whatsapp-bridge
podman-compose up -d whatsapp-bridge
```

### QR Code Not Appearing

```bash
podman-compose logs -f whatsapp-bridge
```

## Credits

- [lharries/whatsapp-mcp](https://github.com/lharries/whatsapp-mcp) — original MCP server
- [FelixIsaac/whatsapp-mcp-extended](https://github.com/FelixIsaac/whatsapp-mcp-extended) — extended fork (41 tools)
- [whatsmeow](https://github.com/tulir/whatsmeow) — Go WhatsApp Web API
- [mcp-proxy](https://pypi.org/project/mcp-proxy/) — SSE-to-stdio bridge

## License

MIT
