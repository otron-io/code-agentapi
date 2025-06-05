# Deployment Guide: AgentAPI with Claude Code on DigitalOcean

This guide walks you through deploying the AgentAPI server with Claude Code to DigitalOcean App Platform with automated deployments.

## Prerequisites

1. **DigitalOcean Account**: Make sure you have a DigitalOcean account
2. **GitHub Repository**: Fork or have access to the AgentAPI repository
3. **Anthropic API Key**: Get your API key from [Anthropic Console](https://console.anthropic.com/)

## Setup Instructions

### 1. DigitalOcean Container Registry

1. Create a Container Registry in DigitalOcean:

   ```bash
   doctl registry create agentapi-registry
   ```

2. Note the registry name for later use.

### 2. DigitalOcean App Platform

1. Go to [DigitalOcean App Platform](https://cloud.digitalocean.com/apps)
2. Click "Create App"
3. Choose "GitHub" as source
4. Select your repository and the `main` branch
5. Choose "Autodeploy code changes" to enable automatic deployments
6. Use the provided `.do/app.yaml` configuration file or configure manually:
   - **Service Name**: `agentapi-server`
   - **Source Directory**: `/` (root)
   - **Dockerfile Path**: `Dockerfile`
   - **HTTP Port**: `3284`
   - **Health Check Path**: `/status`

### 3. Environment Variables

Set the following environment variables in your DigitalOcean app:

1. **Required**:

   - `ANTHROPIC_API_KEY`: Your Anthropic API key (mark as encrypted)

2. **Optional**:
   - `PORT`: `3284` (default)
   - `NODE_ENV`: `production`

### 4. GitHub Secrets

Add the following secrets to your GitHub repository:

1. Go to your GitHub repository → Settings → Secrets and variables → Actions
2. Add these repository secrets:
   - `DIGITALOCEAN_ACCESS_TOKEN`: Your DigitalOcean API token
   - `REGISTRY_NAME`: Your DigitalOcean container registry name
   - `APP_ID`: Your DigitalOcean app ID (found in the app URL)
   - `APP_URL`: Your app's public URL (optional, for notifications)

### 5. GitHub Actions Setup

The deployment workflow (`.github/workflows/deploy.yml`) will automatically:

1. **Trigger** on every push to the `main` branch
2. **Build** the Docker image with AgentAPI and Claude Code
3. **Push** the image to DigitalOcean Container Registry
4. **Deploy** to DigitalOcean App Platform
5. **Notify** about deployment status

## Usage

Once deployed, your AgentAPI server will be available at your DigitalOcean app URL.

### API Endpoints

- `GET /messages` - Get conversation history
- `POST /message` - Send a message to Claude
- `GET /status` - Check server status
- `GET /events` - SSE stream of events
- `GET /chat` - Web chat interface

### Example Usage

```bash
# Send a message to Claude
curl -X POST https://your-app-url.ondigitalocean.app/message \
  -H "Content-Type: application/json" \
  -d '{"content": "Hello Claude! Can you help me with some code?", "type": "user"}'

# Get conversation history
curl https://your-app-url.ondigitalocean.app/messages

# Check server status
curl https://your-app-url.ondigitalocean.app/status
```

### Web Interface

Visit `https://your-app-url.ondigitalocean.app/chat` for a web-based chat interface.

## Monitoring and Logs

1. **App Logs**: View in DigitalOcean App Platform console
2. **Metrics**: Monitor CPU and memory usage in the dashboard
3. **Alerts**: Configured for 80% CPU and memory utilization
4. **Health Checks**: Automatic health monitoring on `/status` endpoint

## Scaling

To scale your deployment:

1. **Vertical Scaling**: Upgrade instance size in App Platform settings
2. **Horizontal Scaling**: Increase instance count (note: each instance will have its own conversation state)

## Troubleshooting

### Common Issues

1. **Deployment Fails**:

   - Check GitHub Actions logs
   - Verify all secrets are correctly set
   - Ensure DigitalOcean API token has proper permissions

2. **Health Check Fails**:

   - Verify the `/status` endpoint is responding
   - Check if Claude Code is properly installed
   - Review application logs

3. **Claude Not Responding**:
   - Verify `ANTHROPIC_API_KEY` is set correctly
   - Check API key permissions and quota
   - Review application logs for errors

### Debugging

1. **View Logs**:

   ```bash
   doctl apps logs <APP_ID> --follow
   ```

2. **Check App Status**:

   ```bash
   doctl apps get <APP_ID>
   ```

3. **Manual Deployment**:
   ```bash
   doctl apps update <APP_ID> --spec .do/app.yaml
   ```

## Cost Considerations

- **Basic XXS**: ~$5/month per instance
- **Container Registry**: Storage costs apply
- **Bandwidth**: Additional charges for high traffic

## Security

- API keys are stored as encrypted environment variables
- Application runs as non-root user
- Health checks ensure service reliability
- HTTPS is enforced by default on App Platform

## Updates

The deployment automatically updates when you push to the `main` branch. For manual updates:

1. Push your changes to `main` branch
2. GitHub Actions will automatically build and deploy
3. Monitor the deployment in GitHub Actions and DigitalOcean console
