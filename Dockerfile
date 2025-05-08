FROM alpine:3.21

LABEL maintainer="Wildlife Studios"

ARG BASH_VERSION=5.2.37-r0
ARG CURL_VERSION=8.11.0-r2
ARG GREP_VERSION=3.11-r0
ARG GIT_VERSION=2.47.1-r0
ARG JQ_VERSION=1.7.1-r0
ARG MAKE_VERSION=4.4.1-r2
ARG PYTHON_VERSION=3.12.8-r1
ARG PY3_PIP_VERSION=24.3.1-r0
ARG ZIP_VERSION=3.0-r13
ARG OPENSSH_VERSION=9.9_p1-r2
ARG KUSTOMIZE_VERSION=5.5.0-r0
ARG FLUX_VERSION=2.4.0-r0
ARG AWS_CLI_VERSION=2.22.10-r0
ARG HELM_VERSION=3.16.3-r0
ARG YQ_VERSION=4.44.5-r0

ARG VAULT_VERSION=1.17.5
ARG CONFTEST_VERSION=0.59.0
ARG TFENV_VERSION=v3.0.0
ARG KUBECTL_VERSION=v1.28.13
ARG TERRAGRUNT=v0.69.9
ARG PSQL_VERSION=15.10-r0
ARG MYSQL_VERSION=11.4.4-r1
ARG ROVER_VERSION=0.3.3
ARG HELM_DIFF_VERSION=v3.9.10
ARG OPA_VERSION=v1.4.2

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
    kustomize=${KUSTOMIZE_VERSION} \
    flux=${FLUX_VERSION} \
    aws-cli=${AWS_CLI_VERSION} \
    helm=${HELM_VERSION} \
    yq-go=${YQ_VERSION}

# OPA
RUN apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
      x86_64) arch=amd64 ;; \
      aarch64) arch=arm64 ;; \
    esac; \
    curl -L -o /usr/bin/opa https://github.com/open-policy-agent/opa/releases/download/v${OPA_VERSION}/opa_linux_${arch} && \
    chmod +x /usr/bin/opa

# Vault
RUN apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
      x86_64) arch=amd64 ;; \
      aarch64)  arch=arm64 ;; \
    esac; \
    curl https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${arch}.zip --output - | \
    busybox unzip -d /usr/bin/ - && \
    chmod +x /usr/bin/vault

# conftest
RUN apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
      x86_64) arch=x86_64 ;; \
      aarch64)  arch=arm64 ;; \
    esac; \
    curl -L https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_${arch}.tar.gz --output - | \
    tar -xzf - -C /usr/local/bin

# rover
RUN apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
      x86_64) arch=amd64 ;; \
      aarch64)  arch=arm64 ;; \
    esac; \
    curl -LO https://github.com/im2nguyen/rover/releases/download/v${ROVER_VERSION}/rover_${ROVER_VERSION}_linux_amd64.zip && \
    busybox unzip -d /tmp/ rover_${ROVER_VERSION}_linux_amd64.zip && \
    mv /tmp/rover_v${ROVER_VERSION} /usr/bin/rover && \
    chmod +x /usr/bin/rover && \
    rm -r /tmp/* && rm rover_${ROVER_VERSION}_linux_amd64.zip

# tfenv (terraform)
RUN git clone -b ${TFENV_VERSION} --single-branch --depth 1 \
    https://github.com/tfutils/tfenv.git /opt/tfenv && \
    ln -s /opt/tfenv/bin/* /usr/local/bin

# Terragrunt
RUN apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
      x86_64) arch=amd64 ;; \
      aarch64)  arch=arm64 ;; \
    esac; \
    curl -L -o /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT}/terragrunt_linux_${arch} && \
    chmod +x /usr/local/bin/terragrunt

# Kubectl
RUN apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
      x86_64) arch=amd64 ;; \
      aarch64)  arch=arm64 ;; \
    esac; \
    curl -L -o /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${arch}/kubectl && \
    chmod u+x /bin/kubectl

#Helm Diff
RUN helm plugin install https://github.com/rsafonseca/helm-diff --version "${HELM_DIFF_VERSION}"

ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "bash" ]
