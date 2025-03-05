# Use an official Python image as the base
FROM python:3.10

# Set the working directory
WORKDIR /app

# Copy Python requirements file
COPY requirements.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project
COPY . .

# Expose the port used by Uvicorn
EXPOSE 8000

# Start the Python application using Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]