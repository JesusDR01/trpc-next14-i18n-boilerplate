# # First we are using a temporal container to install node_modules and have them cached (LAYER1)
# FROM node:20-alpine AS installer
# WORKDIR /app
# COPY package.json yarn.lock ./
# RUN yarn install

# # We send the node_modules from the first temporal container to the second temporal container to do the build
# FROM node:20-alpine AS builder 
# WORKDIR /app
# COPY . .
# COPY --from=installer /app ./
# RUN yarn build


# # Now we get the built .next/standalone to provide the final docker image
# FROM node:20-alpine
# WORKDIR /app

# # Uncomment the following line in case you want to disable telemetry during runtime.
# # ENV NEXT_TELEMETRY_DISABLED 1

# RUN addgroup --system --gid 1001 nodejs
# RUN adduser --system --uid 1001 nextjs

# #COPY --from=builder /app/public ./public

# # Automatically leverage output traces to reduce image size
# # https://nextjs.org/docs/advanced-features/output-file-tracing
# COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
# COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# USER nextjs

# EXPOSE 8000

# ENV PORT 8000

# CMD ["node", "server.js"]



##### DEPENDENCIES

# FROM oven/bun:1 as installer
# WORKDIR /app
# COPY prisma ./
# COPY package.json bun.lockb ./
# ARG NODE_VERSION=20
# RUN apt update \
#     && apt install -y curl
# RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n \
#     && bash n $NODE_VERSION \
#     && rm n \
#     && npm install -g n
# COPY ./package.json ./bun.lockb ./
# COPY ./src ./
# COPY ./prisma ./prisma
# RUN bun install
# RUN bun prisma generate
# RUN ls -l /app
# #RUN bun run postinstall

# ##### BUILDER
# FROM oven/bun:1  AS builder
# WORKDIR /app
# ARG DATABASE_URL
# COPY . .
# COPY --from=installer /app ./
# RUN bun run build

# ##### RUNNER

# # FROM oven/bun:1
# # WORKDIR /app


# # # RUN addgroup --system --gid 1001 nodejs
# # # RUN adduser --system --uid 1001 nextjs
# # COPY --from=builder /app/public ./public
# # COPY --from=builder  /app/.next/standalone ./
# # COPY --from=builder  /app/.next/static ./.next/static

# # #RUN bun run postinstall

# # USER nextjs
# # EXPOSE 3000
# # ENV PORT 3000

# # CMD ["node", "server.js"]



# # First we are using a temporal container to install node_modules and have them cached (LAYER1)
# FROM node:20-alpine AS installer
# WORKDIR /app
# COPY package.json yarn.lock ./
# RUN yarn install

# # We send the node_modules from the first temporal container to the second temporal container to do the build
# FROM node:20-alpine AS builder 
# WORKDIR /app
# COPY . .
# COPY --from=installer /app ./
# RUN yarn build


# # Now we get the built .next/standalone to provide the final docker image
# FROM node:20-alpine
# WORKDIR /app

# # Uncomment the following line in case you want to disable telemetry during runtime.
# # ENV NEXT_TELEMETRY_DISABLED 1

# RUN addgroup --system --gid 1001 nodejs
# RUN adduser --system --uid 1001 nextjs

# #COPY --from=builder /app/public ./public

# # Automatically leverage output traces to reduce image size
# # https://nextjs.org/docs/advanced-features/output-file-tracing
# COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
# COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# USER nextjs

# EXPOSE 3000

# ENV PORT 3000

# CMD ["node", "server.js"]


##### DEPENDENCIES

FROM  node:20-alpine AS deps
RUN apk add --no-cache libc6-compat openssl1.1-compat
WORKDIR /app

# Install Prisma Client - remove if not using Prisma

COPY prisma ./

# Install dependencies based on the preferred package manager

COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml\* ./

RUN \
 if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
 elif [ -f package-lock.json ]; then npm ci; \
 elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i; \
 else echo "Lockfile not found." && exit 1; \
 fi

##### BUILDER

FROM  node:20-alpine AS builder
ARG DATABASE_URL
# ARG NEXT_PUBLIC_CLIENTVAR
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# ENV NEXT_TELEMETRY_DISABLED 1

RUN \
 if [ -f yarn.lock ]; then SKIP_ENV_VALIDATION=1 yarn build; \
 elif [ -f package-lock.json ]; then SKIP_ENV_VALIDATION=1 npm run build; \
 elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && SKIP_ENV_VALIDATION=1 pnpm run build; \
 else echo "Lockfile not found." && exit 1; \
 fi

##### RUNNER

FROM  node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV production

# ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/next.config.mjs ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT 3000

CMD ["node", "server.js"]
