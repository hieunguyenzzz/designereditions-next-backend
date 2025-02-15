# Base image
FROM node:20.11.1-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install

# Copy source code and env file
COPY . .

# Build the application
RUN yarn build

# Change to the build directory
WORKDIR /app/.medusa/server

# Install production dependencies in build directory
RUN yarn install --production

# Set production environment
ENV NODE_ENV=production

# Expose port
EXPOSE 9000

# Start the server
CMD ["node", "index.js"]