# Use an official Python image as the base
FROM python:3.10

# Set the working directory
WORKDIR /app

# Copy Python requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt


# Copy the entire project
COPY . .

# Ensure Uvicorn is installed
RUN pip install uvicorn

RUN apt update && apt install -y ffmpeg

RUN pip install imageio[ffmpeg] imageio-ffmpeg



# Expose the port used by Uvicornnnn
EXPOSE 8000

# Start the Python application using Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]



# Use a base Python image
FROM python:3.10

# Set the working directory inside the container
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


RUN pip install uvicorn

RUN apt update && apt install -y ffmpeg

RUN pip install imageio[ffmpeg] imageio-ffmpeg


# Install Ollama inside the container
RUN curl -fsSL https://ollama.ai/install.sh | sh

RUN  ollama run llama3
# Copy application files
COPY . .

# Expose necessary ports
EXPOSE 8000

# Start Ollama and the FastAPI app
CMD ollama serve --host 0.0.0.0 & uvicorn main:app --host 0.0.0.0 --port 8000
