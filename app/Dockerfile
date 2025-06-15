# ------------------------------
# 1. Use minimal Python base image (Alpine)
#    - Small size (~5MB base)
#    - Fewer system-level vulnerabilities
FROM python:3.10-alpine

# ------------------------------
# 2. Install required system packages
#    - libffi-dev: for cryptographic or Flask extensions (e.g., `flask` or `cryptography`)
#    - build-base: GCC, make, etc. (for compiling C-based packages)
#    - musl-dev: Alpine's libc implementation
#    - --no-cache: prevents caching of package index (reduces image size & attack surface)
RUN apk add --no-cache \
    libffi-dev \
    build-base \
    musl-dev

# ------------------------------
# 3. Create a non-root user
#    - Improves container security
#    - Use `-S` for system user, `-G` to set group
RUN addgroup -S app && adduser -S app -G app

# ------------------------------
# 4. Set the working directory
#    - All following commands will run in /app
WORKDIR /app

# ------------------------------
# 5. Copy the current project files into the container
COPY . .

# ------------------------------
# 6. Install Python dependencies
#    - `--no-cache-dir` reduces image size and prevents temporary file buildup
RUN pip install --no-cache-dir -r requirements.txt

# ------------------------------
# 7. Switch to non-root user created earlier
USER app

# ------------------------------
# 8. Expose the Flask default port (5000)
EXPOSE 5000

# ------------------------------
# 9. Set the command to run your Flask app
CMD ["python", "app.py"]
