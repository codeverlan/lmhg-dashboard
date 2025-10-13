from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
import httpx
import os

bearer_scheme = HTTPBearer(auto_error=False)

HYDRA_INTROSPECT = os.getenv('HYDRA_INTROSPECT_URL', 'http://hydra:4444/oauth2/introspect')
HYDRA_CLIENT_ID = os.getenv('HYDRA_CLIENT_ID', 'lmhg-backend')
HYDRA_CLIENT_SECRET = os.getenv('HYDRA_CLIENT_SECRET', 'replace-me')

async def introspect_token(token: HTTPAuthorizationCredentials = Depends(bearer_scheme)):
    if not token:
        raise HTTPException(status_code=401, detail='Missing token')
    async with httpx.AsyncClient() as client:
        resp = await client.post(HYDRA_INTROSPECT, data={
            'token': token.credentials,
            'client_id': HYDRA_CLIENT_ID,
            'client_secret': HYDRA_CLIENT_SECRET,
        })
        if resp.status_code != 200:
            raise HTTPException(status_code=401, detail='Invalid token')
        data = resp.json()
        if not data.get('active'):
            raise HTTPException(status_code=401, detail='Inactive token')
        return data

async def require_phi_access(claims = Depends(introspect_token)):
    # Ensure user has role permitting PHI access
    roles = claims.get('roles') or claims.get('scope','').split()
    if 'phi:access' not in roles:
        raise HTTPException(status_code=403, detail='Requires PHI access role')
    return claims
