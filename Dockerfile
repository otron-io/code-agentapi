# Use Node.js base image to install Claude Code first
FROM node:18-slim AS node-deps

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Multi-stage build: Go build stage using Ubuntu for better compatibility
FROM golang:1.23-bookworm AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

WORKDIR /app

# Copy source code
COPY . .

# Install dependencies first
RUN cd chat && bun install

# Build the application
RUN make build

# Final stage
FROM node:18-slim

# Install Claude Code globally and curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/* && \
    npm install -g @anthropic-ai/claude-code

# Create app directory
WORKDIR /app

# Copy the built binary from builder stage
COPY --from=builder /app/out/agentapi /usr/local/bin/agentapi

# Create non-root user
RUN useradd -m -u 1001 agentapi
USER agentapi

# Expose port
EXPOSE 3284

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3284/status || exit 1

# Command to run the application
CMD ["agentapi", "server", "--", "claude"] 