# Makefile for common developer tasks

.PHONY: dev up build migrate logs stop restart

.PHONY: build-frontend-prod

dev: build up migrate

build:
	docker compose build

up:
	docker compose up -d

migrate:
	# Run the programmatic alembic runner in the migrate service
	docker compose run --rm migrate

logs:
	docker compose logs --tail 200 -f

stop:
	docker compose down

restart: stop up

build-frontend-prod:
	# Build production frontend image using multi-stage Dockerfile
	docker build -f frontend/Dockerfile.prod -t lmhg-frontend:prod frontend
