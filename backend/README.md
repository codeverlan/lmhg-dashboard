# LMHG Backend (Minimal FastAPI scaffold)

This is a minimal FastAPI backend scaffold with an example model that includes the `hipaa_exempt` flag.

Quick start (using poetry)

```bash
cd backend
poetry install
poetry run uvicorn lmhg.main:app --reload --host 0.0.0.0 --port 8000
```

The scaffold includes:
- `lmhg/main.py` - FastAPI app and a sample endpoint
- `lmhg/models.py` - example SQLModel model with `hipaa_exempt` flag
- `.env.example` with required environment variables

Notes

This is a starting point and intentionally minimal. We can expand with auth, migrations, and database connectivity next.
