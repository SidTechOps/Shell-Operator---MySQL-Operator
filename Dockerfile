# Use mikefarah/yq:4 as the base image
FROM mikefarah/yq:4

# Set the working directory
WORKDIR /operator

# Copy your scripts and templates into the image
COPY /src/resources/mysql-deployment-template.yaml /operator/mysql-deployment-template.yaml
COPY /src/controller/controller-script.sh /operator/controller-script.sh

# Switch to the root user to install necessary packages
USER root

RUN apk add --no-cache bash

# Install curl, wget, kubectl, and jq
RUN apk add --no-cache curl wget jq && \
    wget -O /usr/local/bin/kubectl https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Set the controller script as the entrypoint
ENTRYPOINT ["./controller-script.sh"]
