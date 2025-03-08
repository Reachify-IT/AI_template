# Use NVIDIA CUDA image with Ubuntu 22.04
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# Set working directory
WORKDIR /app

# Prevent APT from asking for user input
ENV DEBIAN_FRONTEND=noninteractive

# Install Python, FFmpeg, Curl, and other dependencies
RUN apt update && apt install -y \
    python3.10 python3.10-venv python3.10-dev python3-pip \
    curl ffmpeg git && \
    ln -sf /usr/bin/python3.10 /usr/bin/python3 && \
    python3 -m pip install --no-cache-dir --upgrade pip 

# Install Ollama inside the container
RUN curl -fsSL https://ollama.ai/install.sh | sh

# Copy project files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose FastAPI and Ollama ports
EXPOSE 8000 11434

# Set entrypoint
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
