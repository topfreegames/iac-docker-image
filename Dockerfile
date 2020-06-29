FROM alpine:3

LABEL maintainer="Wildlife Studios"

ARG BASH_VERSION=5.0.17-r0
ARG CURL_VERSION=7.69.1-r0
ARG GREP_VERSION=3.4-r0
ARG GIT_VERSION=2.26.2-r0
ARG PYTHON_VERSION=3.8.3-r0
ARG JQ_VERSION=1.6-r1
ARG PY3_PIP_VERSION=20.1.1-r0
ARG ZIP_VERSION=3.0-r8



ARG VAULT_VERSION=1.3.4
ARG TFENV_VERSION=1.1.1
ARG AWSCLI_VERSION=1.18.27
ARG MAKE_VERSION=4.3-r0
ARG KUBECTL_VERSION=v1.18.5

# Base dependencies
RUN apk update && \
    apk add --no-cache \
      bash=${BASH_VERSION} \
      curl=${CURL_VERSION} \
      grep=${GREP_VERSION} \
      git=${GIT_VERSION}   \
      python3=${PYTHON_VERSION} \
      make=${MAKE_VERSION} \
      py3-pip=${PY3_PIP_VERSION}  \
      jq=${JQ_VERSION} \
      zip=${ZIP_VERSION}


# Vault
RUN curl https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip --output - | \
      busybox unzip -d /usr/bin/ - && \
      chmod +x /usr/bin/vault

# tfenv (terraform)
RUN git clone -b ${TFENV_VERSION} --single-branch --depth 1 \
      https://github.com/topfreegames/tfenv.git /opt/tfenv && \
      ln -s /opt/tfenv/bin/* /usr/local/bin

# AWS CLI
RUN pip3 install awscli==${AWSCLI_VERSION}

# Kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl /bin/kubectl
RUN chmod u+x /bin/kubectl

ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "bash" ]
