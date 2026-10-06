FROM node:22-trixie-slim AS deps

WORKDIR /app

COPY dist/apps/velero-ui/package.json dist/apps/velero-ui/package-lock.json ./

RUN npm ci --omit=dev && npm cache clean --force

# Distroless runtime: no shell, package manager or npm, which removes most of the
# OS and npm-bundled CVEs reported by image scanners. Runs as the nonroot user.
FROM gcr.io/distroless/nodejs22-debian13:nonroot

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY dist/apps/velero-ui .

ENV NODE_ENV production
ENV HOSTNAME "0.0.0.0"
ENV PORT 3000
ENV VELERO_NAMESPACE velero
ENV AUTH_SECRET_PASSPHRASE "this is not a secret passphrase"
ENV CACHE_DEFAULT_TTL 360000

ENV BASIC_AUTH_ENABLED=true

EXPOSE 3000

# The distroless entrypoint is already `node`.
CMD ["main.js"]
