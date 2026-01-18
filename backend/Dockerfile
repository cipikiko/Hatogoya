# Base image
FROM python:3.10-slim

# Install PostgreSQL client for wait-for-postgres
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend source
COPY . /app

# Copy wait script
COPY wait-for-postgres.sh /app/wait-for-postgres.sh
RUN chmod +x /app/wait-for-postgres.sh

EXPOSE 5000

CMD ["./wait-for-postgres.sh", "postgres", "python", "app.py"]
