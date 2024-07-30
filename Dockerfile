FROM alpine:3.20

LABEL maintainer="Wildlife Studios"

ARG BASH_VERSION=5.2.26-r0
ARG CURL_VERSION=8.8.0-r0
ARG GREP_VERSION=3.11-r0
ARG GIT_VERSION=2.45.2-r0
ARG JQ_VERSION=1.7.1-r0
ARG MAKE_VERSION=4.4.1-r2
ARG PYTHON_VERSION=3.12.3-r1
ARG PY3_PIP_VERSION=24.0-r2
ARG ZIP_VERSION=3.0-r12
ARG OPENSSH_VERSION=9.7_p1-r4
ARG KUSTOMIZE_VERSION=5.3.0-r5


ARG VAULT_VERSION=1.13.5
ARG CONFTEST_VERSION=0.46.0
ARG TFENV_VERSION=1.1.1
ARG KUBECTL_VERSION=v1.27.6
ARG TERRAGRUNT=v0.51.8
ARG PSQL_VERSION=15.7-r0
ARG MYSQL_VERSION=10.11.8-r0
ARG ROVER_VERSION=0.3.3
ARG HELM_DIFF_VERSION=v3.8.2

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
      zip=${ZIP_VERSION} \
      postgresql15-client=${PSQL_VERSION} \
      mysql-client=${MYSQL_VERSION} \
      openssh=${OPENSSH_VERSION} \
      kustomize=${KUSTOMIZE_VERSION}

RUN apk add --no-cache helm aws-cli yq --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
RUN apk add --no-cache opa flux=2.3.0 --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing

# Vault
RUN curl https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip --output - | \
      busybox unzip -d /usr/bin/ - && \
      chmod +x /usr/bin/vault

# conftest
RUN curl -L https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz --output - | \
      tar -xzf - -C /usr/local/bin

# rover
RUN curl -LO https://github.com/im2nguyen/rover/releases/download/v${ROVER_VERSION}/rover_${ROVER_VERSION}_linux_amd64.zip && \
        busybox unzip -d /tmp/ rover_${ROVER_VERSION}_linux_amd64.zip && \
        mv /tmp/rover_v${ROVER_VERSION} /usr/bin/rover && \
        chmod +x /usr/bin/rover && \
        rm -r /tmp/* && rm rover_${ROVER_VERSION}_linux_amd64.zip

# tfenv (terraform)
RUN git clone -b ${TFENV_VERSION} --single-branch --depth 1 \
      https://github.com/topfreegames/tfenv.git /opt/tfenv && \
      ln -s /opt/tfenv/bin/* /usr/local/bin

# Terragrunt
ADD https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT}/terragrunt_linux_amd64 /usr/local/bin/terragrunt
RUN chmod +x /usr/local/bin/terragrunt

# Kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl /bin/kubectl
RUN chmod u+x /bin/kubectl

#Helm Diff
RUN helm plugin install https://github.com/rsafonseca/helm-diff --version "${HELM_DIFF_VERSION}"

ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "bash" ]
