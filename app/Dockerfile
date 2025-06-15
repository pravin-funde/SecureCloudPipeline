# 1. Base image
FROM python:3.10-slim

# 2. Set working directory in container
WORKDIR /app

# 3. Copy local code into container
COPY . .

# 4. Install dependencies without caching to reduce image size # pip install uses --no-cache-dir for security and smaller layers
RUN pip install --no-cache-dir -r requirements.txt 

# 5. Expose Flask’s default port
EXPOSE 5000

# 6. Start the app
CMD ["python", "app.py"]
