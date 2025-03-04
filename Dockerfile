# Base image
FROM node:20.11.1-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache python3 make g++ git

# Copy package files
COPY package.json yarn.lock ./

# Install global Medusa CLI
RUN yarn global add @medusajs/medusa-cli

# Install project dependencies
RUN yarn install

# Copy the rest of the project files
COPY . .

# Build the application
RUN yarn build

# Set production environment
ENV NODE_ENV=production

# Define build-time arguments for sensitive variables
ARG MEDUSA_ADMIN_ONBOARDING_TYPE
ARG STORE_CORS
ARG ADMIN_CORS
ARG AUTH_CORS
ARG REDIS_URL
ARG JWT_SECRET
ARG COOKIE_SECRET
ARG DATABASE_URL
ARG OPENAI_API_KEY

# Set environment variables from build arguments
ENV MEDUSA_ADMIN_ONBOARDING_TYPE=${MEDUSA_ADMIN_ONBOARDING_TYPE:-default}
ENV STORE_CORS=${STORE_CORS:-http://localhost:8000}
ENV ADMIN_CORS=${ADMIN_CORS:-http://localhost:5173,http://localhost:9000}
ENV AUTH_CORS=${AUTH_CORS:-http://localhost:5173,http://localhost:9000,http://localhost:8000}
ENV REDIS_URL=${REDIS_URL}
ENV JWT_SECRET=${JWT_SECRET}
ENV COOKIE_SECRET=${COOKIE_SECRET}
ENV DATABASE_URL=${DATABASE_URL}
ENV OPENAI_API_KEY=${OPENAI_API_KEY}

# Expose Medusa server port
EXPOSE 9000

# Create a non-root user for security
RUN addgroup -S medusa && adduser -S medusa -G medusa
USER medusa

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 http://localhost:9000/health || exit 1

# Start the Medusa server
CMD ["medusa", "start"]