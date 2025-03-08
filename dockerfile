# Use NVIDIA CUDA image with Python 3.10
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# Set working directory
WORKDIR /app

# Install Python 3.10 and dependencies
RUN apt update && apt install -y \
    python3.10 python3.10-venv python3.10-dev python3-pip curl && \
    python3.10 -m ensurepip && \
    ln -s /usr/bin/python3.10 /usr/bin/python3 && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Expose API & Ollama ports
EXPOSE 8000 11434

# Set entrypoint
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
