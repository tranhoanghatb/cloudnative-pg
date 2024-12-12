# Start with the PostgreSQL base image
FROM ghcr.io/cloudnative-pg/postgresql:16.2

# Update package lists and install ping and curl
RUN apt-get update && apt-get install -y --no-install-recommends \
    iputils-ping \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Retain PostgreSQL user and working directory settings
USER postgres
WORKDIR /var/lib/postgresql

# Expose PostgreSQL port (optional, if not already exposed)
EXPOSE 5432
