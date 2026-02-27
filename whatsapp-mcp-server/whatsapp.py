"""WhatsApp send-only functions — wraps the Go bridge REST API."""
import json
import os
from typing import Any

import requests

from lib.bridge import _get_headers

# Bridge API configuration
_bridge_host = os.getenv('BRIDGE_HOST', 'localhost:8080')
if ':' not in _bridge_host:
    _bridge_host = f"{_bridge_host}:8080"
WHATSAPP_API_BASE_URL = f"http://{_bridge_host}/api"


def send_message(recipient: str, message: str) -> dict[str, Any]:
    """Send a WhatsApp message and return structured result with message_id."""
    try:
        if not recipient:
            return {"success": False, "error": "Recipient must be provided"}

        url = f"{WHATSAPP_API_BASE_URL}/send"
        payload = {
            "recipient": recipient,
            "message": message,
        }

        response = requests.post(url, json=payload, headers=_get_headers(), timeout=30)

        if response.status_code == 200:
            result = response.json()
            return {
                "success": result.get("success", False),
                "message_id": result.get("message_id"),
                "timestamp": result.get("timestamp"),
                "recipient": result.get("recipient"),
                "error": result.get("message") if not result.get("success") else None,
            }
        else:
            return {"success": False, "error": f"HTTP {response.status_code} - {response.text}"}

    except requests.RequestException as e:
        return {"success": False, "error": f"Request error: {str(e)}"}
    except json.JSONDecodeError:
        return {"success": False, "error": f"Error parsing response: {response.text}"}
    except Exception as e:
        return {"success": False, "error": f"Unexpected error: {str(e)}"}


def send_file(recipient: str, media_path: str) -> dict[str, Any]:
    """Send a file via WhatsApp and return structured result with message_id."""
    try:
        if not recipient:
            return {"success": False, "error": "Recipient must be provided"}

        if not media_path:
            return {"success": False, "error": "Media path must be provided"}

        if not os.path.isfile(media_path):
            return {"success": False, "error": f"Media file not found: {media_path}"}

        url = f"{WHATSAPP_API_BASE_URL}/send"
        payload = {
            "recipient": recipient,
            "media_path": media_path,
        }

        response = requests.post(url, json=payload, headers=_get_headers(), timeout=30)

        if response.status_code == 200:
            result = response.json()
            return {
                "success": result.get("success", False),
                "message_id": result.get("message_id"),
                "timestamp": result.get("timestamp"),
                "recipient": result.get("recipient"),
                "error": result.get("message") if not result.get("success") else None,
            }
        else:
            return {"success": False, "error": f"HTTP {response.status_code} - {response.text}"}

    except requests.RequestException as e:
        return {"success": False, "error": f"Request error: {str(e)}"}
    except json.JSONDecodeError:
        return {"success": False, "error": f"Error parsing response: {response.text}"}
    except Exception as e:
        return {"success": False, "error": f"Unexpected error: {str(e)}"}
