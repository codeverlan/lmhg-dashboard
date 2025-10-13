from fastapi import APIRouter, Request

router = APIRouter()

@router.get('/oauth2/auth')
async def login_consent(request: Request):
    # Simple stub - in production this should render a consent/login UI
    return {"status": "consent not implemented", "query": dict(request.query_params)}
