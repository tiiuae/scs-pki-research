FROM ubuntu:latest

RUN apt-get update && apt-get install -y apt-transport-https

# Install dependencies
RUN apt-get update && apt-get install -y \
    openssl \
    pcscd \
    libengine-pkcs11-openssl \
    opensc \
    libpcsclite-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get upgrade -y
RUN apt-get install openssh-server -y

#RUN apt-get update & apt-get install -y \
#    openssh-server \
#    && rm -rf /var/lib/apt/lists/*

RUN echo 'root:uyubico123' | chpasswd

RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config

EXPOSE 22

# Copy the udev rules for USB device access
COPY 99-usb.rules /etc/udev/rules.d/

# Set environment variables
ENV OPENSSL_CONF=/etc/ssl/openssl.cnf

# Copy YubiKey OpenSSL configuration file
COPY yubikey_openssl.cnf /etc/ssl/openssl.cnf

# Set working directory
WORKDIR /app

# Copy your signing script into the container
#COPY sign_with_yubikey.sh /app/sign_with_yubikey.sh

# Make the script executable
#RUN chmod +x /app/sign_with_yubikey.sh

# Run the signing script when the container starts
#CMD ["/app/sign_with_yubikey.sh"]

#CMD service pcscd start
#CMD ["/usr/sbin/sshd", "-D"]
CMD service pcscd start && /usr/sbin/sshd -D