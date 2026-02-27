# WhatsApp MCP (Send-Only)

A Dockerized [Model Context Protocol](https://modelcontextprotocol.io/) server that lets Claude Desktop send WhatsApp messages. **Send-only by design** — no ability to read messages, list chats, or access conversation history.

Based on [FelixIsaac/whatsapp-mcp-extended](https://github.com/FelixIsaac/whatsapp-mcp-extended), stripped down to two tools.

## Architecture

```
┌─────────────────────┐     ┌─────────────────────┐
│   whatsapp-bridge   │     │   whatsapp-mcp      │
│   (Go + whatsmeow)  │◄────│   (Python + MCP)    │
│   Port: 8080        │     │   Port: 8081        │
└─────────────────────┘     └─────────────────────┘
```

## Quick Start

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running

### Setup

```bash
git clone https://github.com/<your-username>/whatsapp-mcp.git
cd whatsapp-mcp
./setup.sh
```

Or manually:

```bash
docker compose build
docker compose up -d

# Scan the QR code to link your WhatsApp account
docker compose logs -f whatsapp-bridge
```

Then on your phone: **WhatsApp > Settings > Linked Devices > Link a Device**

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

Restart Claude Desktop.

## Tools

| Tool | Description |
|------|-------------|
| `send_message` | Send a text message to a phone number or group JID |
| `send_file` | Send an image, video, or document to a phone number or group JID |

That's it. No read access, no chat listing, no contact search, no group management.

## Useful Commands

```bash
docker compose logs -f whatsapp-bridge   # QR code / bridge logs
docker compose logs -f whatsapp-mcp      # MCP server logs
docker compose ps                        # container status
docker compose down                      # stop everything
docker compose restart                   # restart services
```

## Troubleshooting

### Client Outdated (405)

```bash
cd whatsapp-bridge
go get -u go.mau.fi/whatsmeow@latest
go mod tidy
cd ..
docker compose build whatsapp-bridge
docker compose up -d whatsapp-bridge
```

### QR Code Not Appearing

```bash
docker compose logs -f whatsapp-bridge
```

## Credits

- [lharries/whatsapp-mcp](https://github.com/lharries/whatsapp-mcp) — original MCP server
- [FelixIsaac/whatsapp-mcp-extended](https://github.com/FelixIsaac/whatsapp-mcp-extended) — extended fork (41 tools)
- [whatsmeow](https://github.com/tulir/whatsmeow) — Go WhatsApp Web API

## License

MIT
