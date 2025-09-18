# Dockerfile - Build XAMPP on Ubuntu
FROM ubuntu:22.04

ARG XAMPP_VERSION="8.1.24-0"
ENV DEBIAN_FRONTEND=noninteractive

# minimal packages needed for installer + curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates perl curl && \
    rm -rf /var/lib/apt/lists/*

# Allow passing a custom installer URL at build time (fallback to common pattern)
ARG XAMPP_URL="https://excellmedia.dl.sourceforge.net/project/xampp/XAMPP%20Linux/8.0.30/xampp-linux-x64-8.0.30-0-installer.run"

# Download and install XAMPP unattended
RUN wget -qO /tmp/xampp-installer.run "$XAMPP_URL" \
 && chmod +x /tmp/xampp-installer.run \
 && /tmp/xampp-installer.run --mode unattended \
 && rm -f /tmp/xampp-installer.run

EXPOSE 80 443 3306

# Simple healthcheck: succeed when root page returns 2xx
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -fsS http://localhost/ || exit 1

# Start XAMPP and tail logs so container stays alive
CMD ["/bin/bash", "-lc", "/opt/lampp/lampp start && tail -F /opt/lampp/logs/access_log /opt/lampp/logs/error_log"]
