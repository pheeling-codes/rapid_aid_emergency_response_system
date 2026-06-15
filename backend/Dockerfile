# Use the official Python slim image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install system dependencies (including GDAL and GEOS for GeoDjango)
RUN apt-get update && apt-get install -y \
    binutils \
    libproj-dev \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt /app/
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the Django project
COPY . /app/

# Provide dummy variables so Django doesn't crash during the isolated build phase
ENV SECRET_KEY="dummy-key-for-build"
ENV DATABASE_URL="sqlite:///dummy.db"

# Collect static files
RUN python manage.py collectstatic --noinput

# Expose port (Render uses the PORT environment variable)
EXPOSE 10000

# Start Daphne using the PORT environment variable provided by Render
CMD daphne -b 0.0.0.0 -p ${PORT:-10000} rapid_aid.asgi:application
