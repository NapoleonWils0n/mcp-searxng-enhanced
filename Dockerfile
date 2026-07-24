# Use the native FreeBSD 15.0 base image
FROM ghcr.io/freebsd/freebsd-toolchain:15.snap

# 1. Bootstrap pkg and install Python + build essentials natively
# We include setuptools, wheel, and cryptography via pkg because they 
# are usually the ones that cause pip to hang during 'backend dependencies' compilation.
RUN env ASSUME_ALWAYS_YES=yes IGNORE_OSVERSION=yes pkg bootstrap && \
    env IGNORE_OSVERSION=yes pkg update && \
    env IGNORE_OSVERSION=yes pkg install -y \
    python312 \
    py312-pip \
    py312-setuptools \
    py312-wheel \
    py312-cryptography \
    py312-sqlite3 \
    py312-httpx \
    py312-beautifulsoup \
    py312-pydantic2 \
    py312-tzdata \
    py312-python-dateutil \
    py312-filetype \
    && pkg clean -y

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN env IGNORE_OSVERSION=yes python3.12 -m pip install --no-cache-dir -r requirements.txt

# Copy the local code to the container
COPY mcp_server.py .

# Define environment variables with default values
# Core configuration
ENV SEARXNG_ENGINE_API_BASE_URL="http://localhost:8080/search"
ENV DESIRED_TIMEZONE="Europe/London"
ENV ODS_CONFIG_PATH="/config/ods_config.json"
ENV PYTHONUNBUFFERED=1

# Search results configuration
ENV IGNORED_WEBSITES=""
ENV RETURNED_SCRAPPED_PAGES_NO="3"
ENV SCRAPPED_PAGES_NO="5"
ENV PAGE_CONTENT_WORDS_LIMIT="5000"
ENV CITATION_LINKS="True"

# Category-specific result limits
ENV MAX_IMAGE_RESULTS="10"
ENV MAX_VIDEO_RESULTS="10"
ENV MAX_FILE_RESULTS="5"
ENV MAX_MAP_RESULTS="5"
ENV MAX_SOCIAL_RESULTS="5"

# Performance and limits
ENV TRAFILATURA_TIMEOUT="15"
ENV SCRAPING_TIMEOUT="20"
ENV CACHE_MAXSIZE="100"
ENV CACHE_TTL_MINUTES="5"
ENV CACHE_MAX_AGE_MINUTES="30"
ENV RATE_LIMIT_REQUESTS_PER_MINUTE="10"
ENV RATE_LIMIT_TIMEOUT_SECONDS="60"

# Run mcp_server.py when the container launches
CMD ["/usr/local/bin/python3.12", "mcp_server.py"]
