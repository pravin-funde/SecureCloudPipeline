
# 1. Base Image (secure + minimal)
# --------------------------
# Use the official Python 3.10 slim image based on Debian Bookworm
# It's smaller than full Debian, and newer than Bullseye (fewer CVEs)
FROM python:3.10-slim-bookworm

# --------------------------
# 2. Environment Configs
# --------------------------
# Prevent Python from writing .pyc files and buffer logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# --------------------------
# 3. Create a non-root user and group
# --------------------------
# This avoids running the app as root inside the container
RUN addgroup --system app && adduser --system --ingroup app app

# --------------------------
# 4. Set Working Directory
# --------------------------
# All subsequent paths will be relative to /app
WORKDIR /app

# --------------------------
# 5. Copy requirements file first (layer caching)
# --------------------------
# This step is separated to avoid reinstalling dependencies unnecessarily
COPY requirements.txt .

# --------------------------
# 6. Install Python and System Dependencies
# --------------------------
# Install required system packages (temporarily), install Python deps, then clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libffi-dev libssl-dev && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y --auto-remove gcc libffi-dev libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# --------------------------
# 7. Copy the Rest of the App
# --------------------------
# Now copy the actual application code into the container
COPY . .

# --------------------------
# 8. Set User
# --------------------------
# Drop privileges and run app as non-root user
USER app

# --------------------------
# 9. Expose the Port
# --------------------------
# Flask default port (helpful for Docker and orchestration tools)
EXPOSE 5000

# --------------------------
# 10. Start the Application
# --------------------------
# This is the default command when the container starts
CMD ["python", "app.py"]
