# Use an official lightweight Python image
FROM python:3.9-slim

# Set the working directory inside the container to /app
WORKDIR /app

# Copy the dependencies file first (for better layer caching)
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose port 5000, which Flask uses by default
EXPOSE 5000

# The command to run when the container starts
CMD ["flask", "run", "--host=0.0.0.0"]
