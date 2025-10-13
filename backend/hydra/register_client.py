"""
Utility to register a client in Ory Hydra using the admin API.
Run in the backend container (requires HYDRA_ADMIN_URL and admin credentials).
"""
import os
import httpx

HYDRA_ADMIN = os.getenv('HYDRA_ADMIN_URL','http://hydra:4444')

async def register_client(client_id: str, redirect_uris: list):
    url = f"{HYDRA_ADMIN}/clients"
    payload = {
        "client_id": client_id,
        "grant_types": ["authorization_code", "refresh_token", "client_credentials"],
        "response_types": ["code","id_token"],
        "scope": "openid offline_access offline phi:access",
        "redirect_uris": redirect_uris,
        "token_endpoint_auth_method": "client_secret_basic"
    }
    async with httpx.AsyncClient() as c:
        r = await c.post(url, json=payload)
        r.raise_for_status()
        return r.json()

if __name__ == '__main__':
    import asyncio
    client = os.getenv('HYDRA_CLIENT_ID','lmhg-backend')
    redirect = os.getenv('HYDRA_CLIENT_REDIRECT','https://localhost:3000/oauth/callback')
    print(asyncio.run(register_client(client,[redirect])))
