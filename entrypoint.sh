#!/bin/bash

# Start Ollama in the background
ollama serve --host 0.0.0.0 &

# Get Ollama's Process ID (PID)
OLLAMA_PID=$!

# Wait for Ollama to start properly
echo "Waiting for Ollama to be ready..."
until curl -s http://localhost:11434/api > /dev/null; do
    echo "Ollama is not ready yet. Retrying in 3 seconds..."
    sleep 3
done

echo "Ollama is ready!"

# Pull the required model
ollama pull llama3

# Start FastAPI using Uvicorn (in the foreground)
exec uvicorn main:app --host 0.0.0.0 --port 8000
