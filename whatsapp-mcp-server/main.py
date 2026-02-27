"""WhatsApp MCP Server — send-only mode (stdio transport)."""
from typing import Any

from mcp.server.fastmcp import FastMCP

from whatsapp import send_file as whatsapp_send_file
from whatsapp import send_message as whatsapp_send_message

mcp = FastMCP("whatsapp")


@mcp.tool()
def send_message(recipient: str, message: str) -> dict[str, Any]:
    """Send a WhatsApp message to a person or group.

    Args:
        recipient: Phone number with country code (no + or symbols),
                   or a JID (e.g., "123456789@s.whatsapp.net" or group "123456789@g.us")
        message: The message text to send

    Returns:
        A dictionary containing success status, message_id, and timestamp
    """
    return whatsapp_send_message(recipient, message)


@mcp.tool()
def send_file(recipient: str, media_path: str) -> dict[str, Any]:
    """Send a file (image, video, document) via WhatsApp.

    Args:
        recipient: Phone number with country code (no + or symbols),
                   or a JID (e.g., "123456789@s.whatsapp.net" or group "123456789@g.us")
        media_path: The absolute path to the media file to send

    Returns:
        A dictionary containing success status, message_id, and timestamp
    """
    return whatsapp_send_file(recipient, media_path)


if __name__ == "__main__":
    mcp.run(transport='stdio')
