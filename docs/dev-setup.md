## Dev setup notes and gotchas

This project uses Docker Compose for local development. A few tips to make the dev stack reliable:

- Frontend (Next.js) volume shadowing: when the `frontend` service mounts `./frontend` into the container, it hides any `node_modules` that were created at image build time. This can result in `sh: next: not found` or similar errors.

- Fix applied: `frontend/docker-entrypoint.sh` now runs `npm install --legacy-peer-deps` on container start if `node_modules` is missing. This keeps the local developer workflow (edit code on host) while ensuring runtime dependencies are present.

- Recommended start sequence (Makefile):

  1. Build images and start services: `make dev` (this runs `build`, `up`, and `migrate`).
  2. Check services: `docker compose ps` and `docker compose logs --tail 200`.
  3. If the frontend complains about packages, run `docker compose exec frontend npm install --legacy-peer-deps`.

- Notes about reproducibility:
  - For CI and production, prefer installing all dependencies during image build (avoid runtime npm install) or use a multi-stage build that copies node_modules into the final image.
  - The Makefile is intentionally minimal to avoid making assumptions about production workflows.

### Production / CI build

Use the provided multi-stage Dockerfile for production builds which installs dependencies during image-build and copies only runtime artifacts into the final image.

Build the production frontend image locally (or in CI):

```bash
make build-frontend-prod
```

This creates an image tagged `lmhg-frontend:prod` that contains preinstalled dependencies and the built Next.js output.

To run the production frontend image via docker-compose (production profile):

```bash
# Start services that are not in the production profile
docker compose --profile production up -d
```

The `frontend-prod` service in `docker-compose.yml` will only be started when the `production` profile is enabled; it pulls `ghcr.io/<owner>/<repo>/lmhg-frontend:prod` by default. Set the `GITHUB_REPOSITORY` env var to change that default.

When the GitHub Actions workflow runs it will publish images to:

```
ghcr.io/<owner>/<repo>/lmhg-frontend:prod
ghcr.io/<owner>/<repo>/lmhg-frontend:latest
```

You can override which image `frontend-prod` uses by setting the `FRONTEND_IMAGE` environment variable when running compose. For example:

```bash
export FRONTEND_IMAGE=ghcr.io/my-org/my-repo/lmhg-frontend:prod
docker compose --profile production up -d
```


