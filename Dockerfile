FROM frolvlad/alpine-glibc:alpine-3.12

LABEL maintainer="Wildlife Studios"

ARG BASH_VERSION=5.0.17-r0
ARG CURL_VERSION=7.77.0-r0
ARG GREP_VERSION=3.4-r0
ARG GIT_VERSION=2.26.3-r0
ARG JQ_VERSION=1.6-r1
ARG MAKE_VERSION=4.3-r0
ARG PYTHON_VERSION=3.8.10-r0
ARG PY3_PIP_VERSION=20.1.1-r0
ARG ZIP_VERSION=3.0-r8

ARG VAULT_VERSION=1.7.2
ARG CONFTEST_VERSION=0.25.0
ARG TFENV_VERSION=1.1.1
ARG KUBECTL_VERSION=v1.21.1
ARG TERRAGRUNT=v0.29.7
ARG OPA_VERSION=v0.29.4

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

# OPA (Open Policy Agent)
RUN curl -fsSL -o /usr/local/bin/opa https://github.com/open-policy-agent/opa/releases/download/${OPA_VERSION}/opa_linux_amd64 && \
      chmod +x /usr/local/bin/opa && \
      opa version

# conftest
RUN curl -L https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz --output - | \
      tar -xzf - -C /usr/local/bin

# tfenv (terraform)
RUN git clone -b ${TFENV_VERSION} --single-branch --depth 1 \
      https://github.com/topfreegames/tfenv.git /opt/tfenv && \
      ln -s /opt/tfenv/bin/* /usr/local/bin

# Terragrunt
ADD https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT}/terragrunt_linux_amd64 /usr/local/bin/terragrunt
RUN chmod +x /usr/local/bin/terragrunt

# AWS CLI v1

RUN pip3 install awscli

# AWS CLI v2
RUN curl -L https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip --output - | \
      busybox unzip -d /tmp/ - && \
      chmod +x -R /tmp/aws && \
      ./tmp/aws/install -i /usr/local/aws-cli-v2 -b /usr/local/bin/aws-cli-v2 && \
      rm -rf ./tmp/aws

RUN echo "if [ ! -z \${AWSCLIV2} ]; then rm -f /usr/bin/aws; ln -s /usr/local/bin/aws-cli-v2/aws /usr/bin/aws; fi" >> ~/.shrc
RUN echo "if [ ! -z \${AWSCLIV2} ]; then rm -f /usr/bin/aws; ln -s /usr/local/bin/aws-cli-v2/aws /usr/bin/aws; fi" >> ~/.bashrc
ENV ENV="/root/.shrc"

# Kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl /bin/kubectl
RUN chmod u+x /bin/kubectl

ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "bash" ]
