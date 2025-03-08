#!/bin/bash

export OLLAMA_HOST="0.0.0.0"
export OLLAMA_CUDA=1  # Ensure GPU support for Ollama

# Ensure Ollama is installed
if ! command -v ollama &> /dev/null
then
    echo "❌ Ollama is not installed! Exiting..."
    exit 1
fi

echo "✅ Starting Ollama with GPU support..."
nohup ollama serve --host=0.0.0.0:11434 > ollama.log 2>&1 &

# Wait for Ollama to start (max 60 seconds)
max_wait=60
counter=0
while ! curl -s http://0.0.0.0:11434/api > /dev/null; do
    echo "⏳ Waiting for Ollama to start..."
    sleep 3
    counter=$((counter+3))
    if [ $counter -ge $max_wait ]; then
        echo "❌ Ollama failed to start after $max_wait seconds."
        exit 1
    fi
done

echo "✅ Ollama is running! Pulling Llama3 Model..."
ollama pull llama3

echo "🚀 Starting FastAPI server..."
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > fastapi.log 2>&1 &

# Keep the container running
wait
