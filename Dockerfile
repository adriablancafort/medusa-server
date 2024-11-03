FROM node:alpine AS build

WORKDIR /app

ARG STORE_CORS=${STORE_CORS}
ARG ADMIN_CORS=${ADMIN_CORS}
ARG AUTH_CORS=${AUTH_CORS}
ARG JWT_SECRET=${JWT_SECRET}
ARG COOKIE_SECRET=${COOKIE_SECRET}
ARG DISABLE_MEDUSA_ADMIN=${DISABLE_MEDUSA_ADMIN}
ARG DATABASE_URL=${DATABASE_URL}
ARG REDIS_URL=${REDIS_URL}

COPY package.json package-lock.json ./

RUN npm ci

COPY . .

RUN npm run build && npm run telemetry && npm run migrate

RUN npm prune --production

FROM node:alpine

COPY --from=build /app/.medusa/server ./
COPY --from=build /app/node_modules ./node_modules

ENV NODE_ENV=production

CMD ["npm", "run", "start"]