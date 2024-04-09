ARG ALPINE_VERSION=3.18
FROM alpine:${ALPINE_VERSION} AS download

# We want to ignore the metadata server, which would normally have high priority,
# because we want to pick up the EKS Service Account role, not the EC2 instance profile role
ENV AWS_EC2_METADATA_DISABLED=false

# We are not using ~/.aws/config or ~/.aws/credentials so we want to prevent
# the AWS SDK from looking for or at them (and complaining they do not exist)
ENV AWS_SDK_LOAD_CONFIG=false

RUN apk -v --no-cache --update add \
    wget \
    ca-certificates && \
    rm -rf /var/cache/apk/*

ARG TARGETOS="linux"
ARG TARGETARCH="amd64"
ARG VERSION="0.7.0"

RUN wget --no-check-certificat https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/${VERSION}/${TARGETOS}-${TARGETARCH}/docker-credential-ecr-login

#RUN wget https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/0.7.0/linux-amd64/docker-credential-ecr-login
RUN chmod +x docker-credential-ecr-login

FROM scratch
LABEL org.opencontainers.image.source=https://github.com/awslabs/amazon-ecr-credential-helper/
COPY --from=download docker-credential-ecr-login /usr/local/bin/docker-credential-ecr-login
RUN chmod a+x /usr/local/bin/docker-credential-ecr-login
ENTRYPOINT ["/usr/local/bin/docker-credential-ecr-login"]