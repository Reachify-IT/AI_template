#!/bin/bash

# Ensure Ollama listens on all interfaces
export OLLAMA_HOST="0.0.0.0"

echo "Starting Ollama..."
ollama serve --host=0.0.0.0:11434 &

# Wait for Ollama to be ready
until curl -s http://127.0.0.1:11434/api > /dev/null; do
    echo "Ollama is not ready yet. Retrying in 3 seconds..."
    sleep 3
done

echo "Ollama is ready!"

# Allow some delay for stability
sleep 5

# Pull the required model
ollama pull llama3

# Start FastAPI on all interfaces
exec uvicorn main:app --host 0.0.0.0 --port 8000
