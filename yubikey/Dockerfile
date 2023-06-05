FROM ubuntu:latest

RUN apt-get update && apt-get install -y apt-transport-https

# Install dependencies
RUN apt-get update && apt-get install -y \
    openssl \
    pcscd \
    libengine-pkcs11-openssl \
    opensc \
    libpcsclite-dev \
    xxd \
    && rm -rf /var/lib/apt/lists/*

# Copy the udev rules for USB device access
COPY 99-usb.rules /etc/udev/rules.d/

# Set environment variables
ENV OPENSSL_CONF=/etc/ssl/openssl.cnf

# Copy YubiKey OpenSSL configuration file
COPY yubikey_openssl.cnf /etc/ssl/openssl.cnf

# Set working directory
WORKDIR /app

COPY sign.sh /app
COPY verify.sh /app
RUN chmod +x /app/sign.sh
RUN chmod +x /app/verify.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]