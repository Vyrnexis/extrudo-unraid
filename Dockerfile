ARG EXTRUDO_VERSION=v0.6.1
ARG EXTRUDO_COMMIT=a93b22a18e694f6f938b2d21d5ad10fff76215f9

FROM node:24-alpine AS build

ARG EXTRUDO_VERSION
ARG EXTRUDO_COMMIT

RUN apk add --no-cache git
WORKDIR /src
RUN git clone --branch "${EXTRUDO_VERSION}" --depth 1 https://github.com/zoltanf/extrudo.git . \
    && test "$(git rev-parse HEAD)" = "${EXTRUDO_COMMIT}"
RUN corepack enable \
    && pnpm install --frozen-lockfile \
    && pnpm wasm \
    && pnpm --filter @extrudo/web build

FROM nginxinc/nginx-unprivileged:1.29-alpine

ARG EXTRUDO_VERSION
LABEL org.opencontainers.image.title="Extrudo for Unraid" \
      org.opencontainers.image.description="Unofficial container packaging of Extrudo" \
      org.opencontainers.image.source="https://github.com/Vyrnexis/extrudo-unraid" \
      org.opencontainers.image.url="https://github.com/zoltanf/extrudo" \
      org.opencontainers.image.licenses="GPL-3.0-or-later" \
      org.opencontainers.image.version="${EXTRUDO_VERSION}"

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/apps/web/dist /usr/share/nginx/html

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -q --spider http://127.0.0.1:8080/healthz || exit 1
