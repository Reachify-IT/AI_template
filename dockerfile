# Use a base Python image
FROM python:3.10

# Set the working directory inside the container
WORKDIR /app

# Install dependencies in one step to leverage caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install uvicorn && \
    apt update && apt install -y ffmpeg && \
    pip install imageio[ffmpeg] imageio-ffmpeg

# Install Ollama inside the container
RUN curl -fsSL https://ollama.ai/install.sh | sh

# Copy application files
COPY . .

# Expose necessary ports
EXPOSE 8000

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Start Ollama and FastAPI with parallel processing
CMD ["uvicorn", "main:app", "--host", "65.2.142.99", "--port", "8000", "--workers", "4"]
