#!/bin/bash
set -x
set -v

apk update && apk add --update --no-cache \
    git \
    bash \
    curl \
    python3 \
    py3-pip \
    py-cryptography \
    curl \
    jq \
    ca-certificates && \
    rm -rf /var/cache/apk/*

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" ;
chmod +x ./kubectl ;
mv ./kubectl /usr/local/bin/kubectl ;

pip install --upgrade pip && \
    pip install --upgrade awscli ; 

echo "deps installed..."
echo "proceeding to secrets creation..."

create_secret() {
    local namespace=$1
    kubectl create secret docker-registry regcred \
        --docker-server=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com \
        --docker-username=AWS \
        --docker-password="$(aws ecr get-login-password --region ${AWS_REGION})" \
        --namespace="${namespace}" \
        --dry-run=client -o yaml | kubectl apply -f -
}

# Extracting namespaces from the NAMESPACES environment variable
IFS=',' read -r -a NAMESPACES <<< "${NAMESPACES}"

# Loop through each namespace and update the secret
for NS in "${NAMESPACES[@]}"; do
  # Check if the secret exists in the namespace
  if kubectl get secret regcred --namespace "${NS}" &> /dev/null; then
    echo "Secret regcred exists in ${NS}, deleting and recreating it..."
    # If it exists, delete it
    kubectl delete secret regcred --namespace "${NS}"
  else
    echo "Secret regcred does not exist in ${NS}, creating it..."
  fi
    # in either scenario we delete the secret or one doesn't exist, so create one
    # Call the create_secret function with the namespace argument
    create_secret "${NS}"
done