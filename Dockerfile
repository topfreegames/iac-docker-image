FROM alpine:3.23

LABEL maintainer="Wildlife Studios"

ARG BASH_VERSION=5.3.3
ARG CURL_VERSION=8.17.0
ARG GREP_VERSION=3.12
ARG GIT_VERSION=2.52.0
ARG JQ_VERSION=1.8.1
ARG MAKE_VERSION=4.4.1
ARG PYTHON_VERSION=3.12.13
ARG PY3_PIP_VERSION=25.1.1
ARG ZIP_VERSION=3.0
ARG OPENSSH_VERSION=10.2_p1
ARG KUSTOMIZE_VERSION=5.7.1
ARG FLUX_VERSION=2.7.3
ARG AWS_CLI_VERSION=2.32.7
ARG HELM_VERSION=3.19.0
ARG YQ_VERSION=4.49.2

ARG VAULT_VERSION=1.17.5
ARG CONFTEST_VERSION=0.59.0
ARG TFENV_VERSION=v3.0.0
ARG KUBECTL_VERSION=v1.28.13
ARG TERRAGRUNT=v0.69.9
ARG PSQL_VERSION=17.9
ARG MYSQL_VERSION=11.4.10
ARG HELM_DIFF_VERSION=v3.15.6-1
ARG OPA_VERSION=v1.4.2

# Base dependencies
RUN apk update && \
    apk add --no-cache \
    bash~=${BASH_VERSION} \
    curl~=${CURL_VERSION} \
    grep~=${GREP_VERSION} \
    git~=${GIT_VERSION}   \
    python3~=${PYTHON_VERSION} \
    make~=${MAKE_VERSION} \
    py3-pip~=${PY3_PIP_VERSION}  \
    jq~=${JQ_VERSION} \
    zip~=${ZIP_VERSION} \
    postgresql17-client~=${PSQL_VERSION} \
    mysql-client~=${MYSQL_VERSION} \
    openssh~=${OPENSSH_VERSION} \
    kustomize~=${KUSTOMIZE_VERSION} \
    flux~=${FLUX_VERSION} \
    aws-cli~=${AWS_CLI_VERSION} \
    helm~=${HELM_VERSION} \
    yq-go~=${YQ_VERSION}

# OPA
RUN apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
      x86_64) arch=amd64 ;; \
      aarch64) arch=arm64 ;; \
    esac; \
    curl -L -o /usr/bin/opa https://github.com/open-policy-agent/opa/releases/download/${OPA_VERSION}/opa_linux_${arch}_static && \
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
    curl -L -o /bin/kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${arch}/kubectl && \
    chmod u+x /bin/kubectl

#Helm Diff
RUN helm plugin install https://github.com/topfreegames/helm-diff --version "${HELM_DIFF_VERSION}"

ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "bash" ]
