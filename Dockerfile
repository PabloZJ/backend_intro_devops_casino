# ─── Stage 1: builder ───────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar solo package.json primero para aprovechar cache de capas
COPY package*.json ./

# npm ci instala exactamente lo del lockfile, más limpio que npm install
RUN npm install --omit=dev
# ─── Stage 2: runtime ───────────────────────────────────────────────────────
FROM node:20-alpine AS runtime

WORKDIR /app

# Copiar dependencias instaladas desde el builder
COPY --from=builder /app/node_modules ./node_modules

# Copiar el código fuente
COPY src/ ./src/
COPY db/  ./db/

# Cambiar al usuario no root que trae la imagen por defecto
USER node

EXPOSE 3000

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "src/server.js"]
