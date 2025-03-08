# Use NVIDIA CUDA image with Ubuntu 22.04
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# Set working directory
WORKDIR /app

# Prevent APT from asking for user input
ENV DEBIAN_FRONTEND=noninteractive

# Update and install Python 3.10 + dependencies
RUN apt update && apt install -y \
    software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt update && apt install -y \
    python3.10 python3.10-venv python3.10-dev python3-pip curl \
    && python3.10 -m ensurepip \
    && ln -sf /usr/bin/python3.10 /usr/bin/python3 \
    && pip install --no-cache-dir --upgrade pip \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose ports for API & Ollama
EXPOSE 8000 11434

# Set entrypoint
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
