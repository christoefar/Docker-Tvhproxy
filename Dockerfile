FROM alpine:3.6

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

# Install core packages
RUN apk add --no-cache \
        ca-certificates \
        coreutils \
        tzdata \
        git \
        openssh && \
      
# SSH files
    mkdir -p /root/.ssh/ && \
    echo "$SSH_KEY" > /root/.ssh/id_rsa && \
    chmod -R 600 /root/.ssh/ && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# Install build packages
    apk add --no-cache --virtual=build-dependencies \
        wget && \

# Create user
    adduser -H -D -S -u 99 -G users -s /sbin/nologin duser && \

# Install runtime packages
    apk add --no-cache \
        python \
        py-pip \
        py-flask \
        py-requests \
        py-gevent && \

# Install tvhproxy
    mkdir -p /opt/tvhproxy && \
    git clone git@github.com:christoefar/tvhProxy.git /opt/tvhproxy
    
# Cleanup
    apk del --purge build-dependencies && \
    rm -rf /var/cache/apk/* /tmp/* && \

# Set file permissions
    chmod +x /docker-entrypoint.sh /opt/tvhproxy/tvhProxy.py

RUN pip install -r  /opt/tvhproxy/requirements.txt

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5004/tcp
