from typing import List
from sqlmodel import SQLModel, Field, create_engine, Session, select

class Record(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    title: str
    data: str
    hipaa_exempt: bool = False

import os

DB_URL = os.getenv("DATABASE_URL", "sqlite:///./example.db")
engine = create_engine(DB_URL, echo=False)

def create_example_db():
    SQLModel.metadata.create_all(engine)
    # insert a couple of example records if empty
    with Session(engine) as session:
        count = session.exec(select(Record)).all()
        if len(count) == 0:
            r1 = Record(title="Non-sensitive note", data="Public info", hipaa_exempt=True)
            r2 = Record(title="Sensitive client note", data="PHI here", hipaa_exempt=False)
            session.add_all([r1, r2])
            session.commit()

def select_all() -> List[Record]:
    with Session(engine) as session:
        return session.exec(select(Record)).all()
