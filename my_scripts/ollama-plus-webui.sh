#!/bin/bash

# === Ollama + Open WebUI Controller Script (MacOS) ===
# This script assumes PROJECT_PATH is configured with:
# 1. pyenv - for automatically selecting the supported python version
# 2. A venv with open-webui installed through pip
# Usage: ./ollama-plus-webui.sh start | stop

# open-webui project path
PROJECT_PATH="$HOME/projects/python/open-webui"
WEBUI_PORT=8090
WEBUI_URL="http://localhost:$WEBUI_PORT"
WEBUI_CMD="open-webui serve --port $WEBUI_PORT"
VENV="$PROJECT_PATH/.venv/bin/activate"

# Parse action argument (start or stop)
COMMAND="$1"
if [ -z "$COMMAND" ]; then
    echo "❌ Usage: $0 [start|stop]"
    exit 1
fi

# Move into the project directory
cd "$PROJECT_PATH" || {
    echo "❌ Could not change to directory: $PROJECT_PATH"
    exit 1
}

if [ "$COMMAND" = "start" ]; then
    echo "🚀 Starting Ollama..."
    brew services start ollama

    if [ -f "$VENV" ]; then
        echo "🐍 Activating virtual environment..."
        source "$VENV"
    else
        echo "⚠️  No virtual environment found at $VENV — skipping."
    fi

    if pgrep -f "$WEBUI_CMD" > /dev/null; then
        echo "✅ Open WebUI is already running."
        echo ""
        echo "🌐 WebUI: $WEBUI_URL"
        echo ""
        exit 0
    fi

    echo ""
    echo "🖥️  Starting Open WebUI at:"
    echo "$WEBUI_URL"
    echo ""
    $WEBUI_CMD

elif [ "$COMMAND" = "stop" ]; then
    echo "🛑 Stopping Ollama..."
    brew services stop ollama

    echo "🛑 Stopping Open WebUI..."
    pkill -f "$WEBUI_CMD"

    echo "✅ All services stopped."

else
    echo "❌ Unknown command: $COMMAND"
    echo "Use: start | stop"
    exit 1
fi
