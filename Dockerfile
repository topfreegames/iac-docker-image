FROM alpine:3

LABEL maintainer="Wildlife Studios"

ARG BASH_VERSION=5.0.11-r1
ARG CURL_VERSION=7.67.0-r0
ARG GREP_VERSION=3.3-r0
ARG GIT_VERSION=2.24.1-r0
ARG PYTHON_VERSION=3.8.2-r0

ARG VAULT_VERSION=1.3.4
ARG TFENV_VERSION=1.1.1
ARG AWSCLI_VERSION=1.18.27

# Base dependencies
RUN apk update && \
    apk add --no-cache \
      bash=${BASH_VERSION} \
      curl=${CURL_VERSION} \
      grep=${GREP_VERSION} \
      git=${GIT_VERSION}   \
      python3=${PYTHON_VERSION}

# Vault
RUN curl https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip --output - | \
      unzip -d /usr/bin/ - && \
      chmod +x /usr/bin/vault

# tfenv (terraform)
RUN git clone -b ${TFENV_VERSION} --single-branch --depth 1 \
      https://github.com/topfreegames/tfenv.git /opt/tfenv && \
      ln -s /opt/tfenv/bin/* /usr/local/bin

# AWS CLI
RUN pip3 install awscli==${AWSCLI_VERSION}

ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "bash" ]
