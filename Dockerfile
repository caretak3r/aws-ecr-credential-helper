ARG ALPINE_VERSION=3.18
FROM alpine:${ALPINE_VERSION}

RUN apk update && apk add --update --no-cache \
    git \
    bash \
    curl \
    openssh \
    python3 \
    py3-pip \
    py-cryptography \
    wget \
    curl \
    jq \
    ca-certificates && \
    rm -rf /var/cache/apk/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

# Install AWSCLI
RUN pip install --upgrade pip && \
    pip install --upgrade awscli 

WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]