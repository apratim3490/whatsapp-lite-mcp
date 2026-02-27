# WhatsApp MCP

A Dockerized [Model Context Protocol](https://modelcontextprotocol.io/) server that connects WhatsApp to Claude Desktop, Cursor, and other MCP clients. Provides **41 tools** for messaging, group management, presence, polls, reactions, and more.

Based on [FelixIsaac/whatsapp-mcp-extended](https://github.com/FelixIsaac/whatsapp-mcp-extended), which extends the [original whatsapp-mcp](https://github.com/lharries/whatsapp-mcp) by lharries.

## Architecture

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│   whatsapp-bridge   │     │   whatsapp-mcp      │     │      web-ui         │
│   (Go + whatsmeow)  │◄────│   (Python + MCP)    │     │   (Next.js SPA)     │
│   Port: 8080        │     │   Ports: 8081, 8082 │     │   Port: 8090        │
└─────────────────────┘     └─────────────────────┘     └─────────────────────┘
         │                           │
         ▼                           ▼
    ┌─────────────────────────────────────┐
    │           SQLite (store/)           │
    └─────────────────────────────────────┘
```

## Quick Start

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running

### Setup

```bash
# Clone and run the setup script
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

Then on your phone: **WhatsApp → Settings → Linked Devices → Link a Device**

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

Restart Claude Desktop — you should see WhatsApp tools available.

## Tools (41)

### Messaging
| Tool | Description |
|------|-------------|
| `send_message` | Send text message |
| `send_file` | Send image/video/document |
| `send_audio_message` | Send voice message |
| `download_media` | Download received media |
| `send_reaction` | React to message with emoji |
| `edit_message` | Edit sent message |
| `delete_message` | Delete/revoke message |
| `mark_read` | Mark messages as read |

### Chats & Messages
| Tool | Description |
|------|-------------|
| `list_chats` | List all chats |
| `get_chat` | Get chat by JID |
| `list_messages` | Search messages with filters |
| `get_message_context` | Get messages around a specific message |
| `get_direct_chat_by_contact` | Find DM with contact |
| `get_contact_chats` | All chats involving contact |
| `get_last_interaction` | Most recent message with contact |
| `request_history` | Request older message history |

### Contacts
| Tool | Description |
|------|-------------|
| `search_contacts` | Search by name/phone |
| `list_all_contacts` | List all contacts |
| `get_contact_details` | Full contact info |
| `set_nickname` / `get_nickname` / `remove_nickname` / `list_nicknames` | Custom nicknames |

### Groups
| Tool | Description |
|------|-------------|
| `get_group_info` | Group metadata & participants |
| `create_group` | Create new group |
| `add_group_members` / `remove_group_members` | Manage members |
| `promote_to_admin` / `demote_admin` | Manage admins |
| `leave_group` | Leave group |
| `update_group` | Update name/topic |
| `create_poll` | Create poll in chat |

### Presence & Profile
| Tool | Description |
|------|-------------|
| `set_presence` | Set online/offline status |
| `subscribe_presence` | Subscribe to contact's presence |
| `get_profile_picture` | Get profile picture URL |
| `get_blocklist` / `block_user` / `unblock_user` | Block management |

### Newsletters
| Tool | Description |
|------|-------------|
| `follow_newsletter` / `unfollow_newsletter` | Follow/unfollow channels |
| `create_newsletter` | Create new channel |

## Useful Commands

```bash
docker compose logs -f whatsapp-bridge   # QR code / bridge logs
docker compose logs -f whatsapp-mcp      # MCP server logs
docker compose ps                        # container status
docker compose down                      # stop everything
docker compose restart                   # restart services
docker compose build && docker compose up -d  # rebuild after changes
```

## Ports

| Service | Port | Description |
|---------|------|-------------|
| Bridge API | 8080 | Go WhatsApp bridge |
| MCP Server | 8081 | SSE transport for Claude |
| Gradio UI | 8082 | Web testing UI |
| Web UI | 8090 | Pairing + webhook management |

## Troubleshooting

### Client Outdated (405)

Update whatsmeow and rebuild:

```bash
cd whatsapp-bridge
go get -u go.mau.fi/whatsmeow@latest
go mod tidy
cd ..
docker compose build whatsapp-bridge
docker compose up -d whatsapp-bridge
```

### Messages Not Delivering

```bash
docker compose restart whatsapp-bridge
docker compose logs --tail=20 whatsapp-bridge
```

### QR Code Not Appearing

```bash
docker compose logs -f whatsapp-bridge
```

## Credits

- [lharries/whatsapp-mcp](https://github.com/lharries/whatsapp-mcp) — original MCP server
- [AdamRussak/whatsapp-mcp](https://github.com/AdamRussak/whatsapp-mcp) — webhooks, container split
- [FelixIsaac/whatsapp-mcp-extended](https://github.com/FelixIsaac/whatsapp-mcp-extended) — reactions, groups, polls, presence, newsletters (41 tools)
- [whatsmeow](https://github.com/tulir/whatsmeow) — Go WhatsApp Web API
- [FastMCP](https://github.com/jlowin/fastmcp) — Python MCP SDK

## License

MIT
