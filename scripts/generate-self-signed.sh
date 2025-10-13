#!/bin/bash
# Generate a self-signed cert for local testing
mkdir -p nginx/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/certs/server.key -out nginx/certs/server.crt \
  -subj "/C=US/ST=State/L=City/O=LMHG/CN=localhost"

echo "Generated nginx/certs/server.key and server.crt"
