# WhatsApp MCP (Send-Only)

A containerized [Model Context Protocol](https://modelcontextprotocol.io/) server that lets Claude send WhatsApp messages. **Send-only by design** — no ability to read messages, list chats, or access conversation history.

Based on [FelixIsaac/whatsapp-mcp-extended](https://github.com/FelixIsaac/whatsapp-mcp-extended), stripped down to two tools.

## Architecture

```
┌─────────────────────┐     ┌─────────────────────┐
│   whatsapp-bridge   │     │   whatsapp-mcp      │
│   (Go + whatsmeow)  │◄────│   (Python + MCP)    │
│   Internal: 8080    │     │   Port: 8081        │
│   (docker-only)     │     │   (host-exposed)    │
└─────────────────────┘     └─────────────────────┘
```

**Security layers:**
- The Go bridge is **not exposed to the host** — only reachable within the Docker network
- Only 2 API routes are registered: `/api/health` and `/api/send` (37 others stripped)
- The MCP server exposes only `send_message` and `send_file` tools via SSE on port 8081

## Quick Start

### Prerequisites

- **Podman** (recommended, open source): `brew install podman && pip3 install podman-compose`
- Or **Docker** with Docker Compose

### Setup

```bash
git clone https://github.com/apratim3490/whatsapp-lite-mcp.git
cd whatsapp-lite-mcp
./setup.sh
```

Or for subsequent starts:

```bash
./start.sh
```

Then scan the QR code to link your WhatsApp account:

```bash
podman logs -f whatsapp-mcp_whatsapp-bridge_1
```

On your phone: **WhatsApp > Settings > Linked Devices > Link a Device**

### Connect to Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "whatsapp": {
      "url": "http://localhost:8081/sse"
    }
  }
}
```

### Connect to Claude Code

Add to `~/.claude.json`:

```json
{
  "mcpServers": {
    "whatsapp": {
      "url": "http://localhost:8081/sse"
    }
  }
}
```

## Tools

| Tool | Description |
|------|-------------|
| `send_message` | Send a text message to a phone number or group JID |
| `send_file` | Send an image, video, or document to a phone number or group JID |

That's it. No read access, no chat listing, no contact search, no group management.

## Useful Commands

```bash
podman-compose logs -f whatsapp-bridge   # QR code / bridge logs
podman-compose logs -f whatsapp-mcp      # MCP server logs
podman-compose ps                        # container status
podman-compose down                      # stop everything
```

Replace `podman-compose` with `docker compose` if using Docker.

## Troubleshooting

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
podman logs -f whatsapp-mcp_whatsapp-bridge_1
```

## Credits

- [lharries/whatsapp-mcp](https://github.com/lharries/whatsapp-mcp) — original MCP server
- [FelixIsaac/whatsapp-mcp-extended](https://github.com/FelixIsaac/whatsapp-mcp-extended) — extended fork (41 tools)
- [whatsmeow](https://github.com/tulir/whatsmeow) — Go WhatsApp Web API

## License

MIT
