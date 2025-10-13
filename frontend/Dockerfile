FROM node:20-alpine
WORKDIR /app

COPY package.json package-lock.json* pnpm-lock.yaml* /app/
RUN npm install --legacy-peer-deps

COPY . /app

RUN npm run build || true

EXPOSE 3000
CMD ["npm", "run", "dev"]
