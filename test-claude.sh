#!/bin/bash

# Test script for AgentAPI Claude deployment
# Usage: ./test-claude.sh [server-url]

SERVER_URL=${1:-"https://agentapi-server-o2wiq.ondigitalocean.app"}

echo "🧪 Testing AgentAPI Claude Server at: $SERVER_URL"
echo "=================================================="

# Test 1: Server health check
echo "1. Testing server status..."
STATUS=$(curl -s "$SERVER_URL/status")
if [[ $STATUS == *"stable"* ]]; then
    echo "   ✅ Server is running and stable"
else
    echo "   ❌ Server status: $STATUS"
    exit 1
fi

# Test 2: Check if Claude has started
echo ""
echo "2. Checking Claude initialization..."
MESSAGES=$(curl -s "$SERVER_URL/messages")
if [[ $STATUS == *"Welcome to Claude Code"* ]]; then
    echo "   ✅ Claude has started successfully"
else
    echo "   ⚠️  Claude may still be initializing"
fi

# Test 3: Send a simple message
echo ""
echo "3. Testing simple message (theme selection)..."
RESPONSE=$(curl -s -X POST "$SERVER_URL/message" \
    -H "Content-Type: application/json" \
    -d '{"content": "1", "type": "user"}')

if [[ $RESPONSE == *"ok"*true* ]]; then
    echo "   ✅ Simple message sent successfully"
    
    # Wait a moment for processing
    sleep 3
    
    # Check updated messages
    UPDATED_MESSAGES=$(curl -s "$SERVER_URL/messages")
    MESSAGE_COUNT=$(echo "$UPDATED_MESSAGES" | grep -o '"id":[0-9]' | wc -l)
    echo "   📊 Total messages in conversation: $MESSAGE_COUNT"
else
    echo "   ❌ Failed to send simple message: $RESPONSE"
fi

# Test 4: Test API documentation
echo ""
echo "4. Testing API documentation..."
DOCS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL/docs")
if [[ $DOCS_STATUS == "200" ]]; then
    echo "   ✅ API documentation is accessible"
else
    echo "   ❌ API documentation failed with status: $DOCS_STATUS"
fi

# Test 5: Test chat interface
echo ""
echo "5. Testing chat web interface..."
CHAT_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL/chat")
if [[ $CHAT_STATUS == "200" ]]; then
    echo "   ✅ Chat interface is accessible"
else
    echo "   ❌ Chat interface failed with status: $CHAT_STATUS"
fi

echo ""
echo "🎯 Test Summary"
echo "==============="
echo "Server URL: $SERVER_URL"
echo "Chat Interface: $SERVER_URL/chat"
echo "API Documentation: $SERVER_URL/docs"
echo ""
echo "To interact with Claude:"
echo "• Use the web interface at $SERVER_URL/chat"
echo "• Send API requests to $SERVER_URL/message"
echo "• Monitor status at $SERVER_URL/status" 