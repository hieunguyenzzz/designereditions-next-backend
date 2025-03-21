# Base image
FROM node:20.11.1-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache python3 make g++ git

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy .env file if it exists - this will be handled by a script
# during build time, not in Dockerfile

# Copy the rest of the project files
COPY . .

# Build the application
RUN yarn build

# Expose Medusa server port
EXPOSE 9000

# Create a non-root user for security
RUN addgroup -S medusa && adduser -S medusa -G medusa

# Set proper permissions
RUN chown -R medusa:medusa /app

# Switch to non-root user
USER medusa

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 http://localhost:9000/health || exit 1

# Start the Medusa server
CMD ["yarn", "start"]