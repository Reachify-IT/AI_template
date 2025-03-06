#!/bin/bash

# Set Ollama to listen on 0.0.0.0 (all interfaces)
export OLLAMA_HOST=0.0.0.0:11434

echo "Starting Ollama..."
ollama serve &

# Wait for Ollama to be ready
until curl -s http://0.0.0.0:11434/api > /dev/null; do
    echo "Ollama is not ready yet. Retrying in 3 seconds..."
    sleep 3
done

echo "Ollama is ready!"

# Pull the required model
ollama pull llama3

# Start FastAPI
exec uvicorn main:app --host 0.0.0.0 --port 8000
