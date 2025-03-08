#!/bin/bash

export OLLAMA_HOST="0.0.0.0"
export OLLAMA_CUDA=1  # Enable GPU for Ollama

echo "Starting Ollama with GPU support..."
nohup ollama serve --host=0.0.0.0:11434 > ollama.log 2>&1 &

# Wait for Ollama to be ready globallyss
(
    until curl -s http://0.0.0.0:11434/api > /dev/null; do
        echo "Waiting for Ollama to start..."
        sleep 3
    done
    echo "Ollama is ready! Pulling Llama3 Model..."
    ollama pull llama3
) &  # Run this as a background process

echo "Starting FastAPI server..."
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > fastapi.log 2>&1 &

# Keep the container running
wait
