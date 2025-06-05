#!/bin/bash

# AgentAPI DigitalOcean Deployment Setup Script
# This script helps you set up the deployment configuration

set -e

echo "🚀 AgentAPI DigitalOcean Deployment Setup"
echo "========================================"

# Check if doctl is installed
if ! command -v doctl &> /dev/null; then
    echo "❌ doctl is not installed. Please install it first:"
    echo "   https://docs.digitalocean.com/reference/doctl/how-to/install/"
    exit 1
fi

# Check if doctl is authenticated
if ! doctl account get &> /dev/null; then
    echo "❌ doctl is not authenticated. Please run:"
    echo "   doctl auth init"
    exit 1
fi

echo "✅ doctl is installed and authenticated"

# Create container registry
echo ""
echo "📦 Setting up Container Registry..."
read -p "Enter registry name (default: agentapi-registry): " REGISTRY_NAME
REGISTRY_NAME=${REGISTRY_NAME:-agentapi-registry}

if doctl registry create $REGISTRY_NAME 2>/dev/null; then
    echo "✅ Container registry '$REGISTRY_NAME' created"
else
    echo "ℹ️  Container registry '$REGISTRY_NAME' may already exist"
fi

# Get registry info
REGISTRY_URL=$(doctl registry get $REGISTRY_NAME --format Name --no-header 2>/dev/null || echo $REGISTRY_NAME)

# Create app
echo ""
echo "🏗️  Setting up App Platform..."
read -p "Enter app name (default: agentapi-claude-server): " APP_NAME
APP_NAME=${APP_NAME:-agentapi-claude-server}

# Check if app.yaml exists and update it
if [ -f ".do/app.yaml" ]; then
    sed -i.bak "s/name: .*/name: $APP_NAME/" .do/app.yaml
    echo "✅ Updated .do/app.yaml with app name: $APP_NAME"
fi

echo ""
echo "🔐 Environment Setup"
echo "==================="

read -p "Enter your Anthropic API key: " -s ANTHROPIC_API_KEY
echo ""

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ Anthropic API key is required"
    exit 1
fi

echo ""
echo "📋 GitHub Secrets Configuration"
echo "================================"
echo ""
echo "Add the following secrets to your GitHub repository:"
echo "(Go to: Repository → Settings → Secrets and variables → Actions)"
echo ""
echo "DIGITALOCEAN_ACCESS_TOKEN: $(doctl auth list --format=Token --no-header | head -n1)"
echo "REGISTRY_NAME: $REGISTRY_NAME"
echo "ANTHROPIC_API_KEY: $ANTHROPIC_API_KEY"
echo ""

# Create or update the app
if [ -f ".do/app.yaml" ]; then
    echo "🚀 Creating DigitalOcean App..."
    
    if APP_INFO=$(doctl apps create --spec .do/app.yaml 2>/dev/null); then
        APP_ID=$(echo "$APP_INFO" | grep -E "^ID" | awk '{print $2}' | head -n1)
        APP_URL=$(echo "$APP_INFO" | grep -E "^Live URL" | awk '{print $3}' | head -n1)
        
        echo "✅ App created successfully!"
        echo "   App ID: $APP_ID"
        echo "   URL: $APP_URL"
        echo ""
        echo "Add these additional GitHub secrets:"
        echo "APP_ID: $APP_ID"
        echo "APP_URL: $APP_URL"
    else
        echo "ℹ️  App creation failed or app may already exist."
        echo "   You can create it manually using: doctl apps create --spec .do/app.yaml"
    fi
else
    echo "❌ .do/app.yaml not found!"
    exit 1
fi

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Next steps:"
echo "1. Add the GitHub secrets shown above to your repository"
echo "2. Set the ANTHROPIC_API_KEY environment variable in your DigitalOcean app"
echo "3. Push to main branch to trigger deployment"
echo ""
echo "Your AgentAPI server will be available at: $APP_URL"
echo "Chat interface: $APP_URL/chat"
echo ""
echo "Monitor deployment: https://cloud.digitalocean.com/apps" 