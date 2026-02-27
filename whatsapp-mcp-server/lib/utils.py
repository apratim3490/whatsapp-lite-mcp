"""Utility functions and logging setup for WhatsApp MCP server."""
import logging
import os


def setup_logging(debug: bool = False) -> logging.Logger:
    """Configure and return the application logger."""
    level = logging.DEBUG if debug else logging.INFO
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    return logging.getLogger("whatsapp-mcp")


logger = setup_logging(os.getenv("DEBUG", "false").lower() == "true")

# Bridge API configuration
_bridge_host = os.getenv('BRIDGE_HOST', 'localhost:8080')
if ':' not in _bridge_host:
    _bridge_host = f"{_bridge_host}:8080"
WHATSAPP_API_BASE_URL = f"http://{_bridge_host}/api"
