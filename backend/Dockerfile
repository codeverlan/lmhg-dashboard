FROM python:3.11-slim
WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y build-essential libpq-dev && rm -rf /var/lib/apt/lists/*

# Install poetry
RUN pip install --no-cache-dir poetry

COPY pyproject.toml poetry.lock* /app/
RUN poetry config virtualenvs.create false && poetry install --no-dev --no-interaction

COPY . /app

ENV PYTHONUNBUFFERED=1

CMD ["uvicorn", "lmhg.main:app", "--host", "0.0.0.0", "--port", "8000"]
