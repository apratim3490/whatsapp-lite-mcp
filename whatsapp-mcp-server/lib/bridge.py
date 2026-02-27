"""Bridge API client for WhatsApp Go bridge."""
import os

from .utils import logger


class BridgeError(Exception):
    """Exception for bridge API errors."""
    pass


def _get_headers() -> dict[str, str]:
    """Get request headers including API key if configured."""
    headers = {"Content-Type": "application/json"}
    api_key = os.getenv("API_KEY")
    logger.info(f"[BRIDGE-HEADERS] API_KEY loaded: {bool(api_key)}")
    if api_key:
        headers["X-API-Key"] = api_key
    return headers
