from fastapi import FastAPI, Depends
from .models import Record, create_example_db, select_all
from .consent import router as consent_router

app = FastAPI(title="LMHG Backend")

# create an in-memory/example sqlite DB for scaffold demo
create_example_db()

app.include_router(consent_router)

@app.get("/")
def root():
    return {"message": "LMHG backend running"}

@app.get("/records")
def list_records():
    # example endpoint returning records
    records = select_all()
    return {"count": len(records), "records": records}

from .auth import require_phi_access


@app.get("/phi-records")
def list_phi_records(claims=Depends(require_phi_access)):
    # returns only HIPAA-sensitive records; protected by introspection
    records = [r for r in select_all() if not r.hipaa_exempt]
    return {"count": len(records), "records": records}
