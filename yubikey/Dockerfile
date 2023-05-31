FROM ubuntu:latest

RUN mkdir /shared
VOLUME /shared

RUN apt-get update && apt-get install -y apt-transport-https

# Install dependencies
RUN apt-get update && apt-get install -y \
    openssl \
    pcscd \
    libengine-pkcs11-openssl \
    opensc \
    libpcsclite-dev \
    && rm -rf /var/lib/apt/lists/*

# Install openssh and run sshd.
# Should be removed from final version!

#RUN apt-get update && \
#    apt-get upgrade -y
#RUN apt-get install openssh-server -y

#RUN echo 'root:uyubico123' | chpasswd

#RUN mkdir /var/run/sshd
#RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#RUN sed -i 's/PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config

#EXPOSE 22

# Copy the udev rules for USB device access
COPY 99-usb.rules /etc/udev/rules.d/

# Set environment variables
ENV OPENSSL_CONF=/etc/ssl/openssl.cnf

# Copy YubiKey OpenSSL configuration file
COPY yubikey_openssl.cnf /etc/ssl/openssl.cnf

# Set working directory
WORKDIR /app

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]