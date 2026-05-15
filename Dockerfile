FROM alpine:3.23

LABEL maintainer="Wildlife Studios"

# renovate: datasource=repology depName=alpine_3_23/bash versioning=loose
ARG BASH_VERSION=5.3.3

# renovate: datasource=repology depName=alpine_3_23/curl versioning=loose
ARG CURL_VERSION=8.19.0-r0

# renovate: datasource=repology depName=alpine_3_23/grep versioning=loose
ARG GREP_VERSION=3.12

# renovate: datasource=repology depName=alpine_3_23/git versioning=loose
ARG GIT_VERSION=2.52.0

# renovate: datasource=github-releases depName=jqlang/jq
ARG JQ_VERSION=1.8.1

# renovate: datasource=repology depName=alpine_3_23/make versioning=loose
ARG MAKE_VERSION=4.4.1

# renovate: datasource=repology depName=alpine_3_23/python3 versioning=loose
ARG PYTHON_VERSION=3.12.13

# renovate: datasource=pypi depName=pip
ARG PY3_PIP_VERSION=25.3

# renovate: datasource=repology depName=alpine_3_23/zip versioning=loose
ARG ZIP_VERSION=3.0

# renovate: datasource=repology depName=alpine_3_23/openssh versioning=loose
ARG OPENSSH_VERSION=10.2_p1-r0

# renovate: datasource=repology depName=alpine_3_23/kustomize versioning=loose
ARG KUSTOMIZE_VERSION=5.7.1

# renovate: datasource=repology depName=alpine_3_23/flux versioning=loose
ARG FLUX_VERSION=2.7.3

# renovate: datasource=repology depName=alpine_3_23/aws-cli versioning=loose
ARG AWS_CLI_VERSION=2.32.7

# renovate: datasource=repology depName=alpine_3_23/helm versioning=loose
ARG HELM_VERSION=3.19.0

# renovate: datasource=repology depName=alpine_3_23/yq-go versioning=loose
ARG YQ_VERSION=4.49.2

# renovate: datasource=github-releases depName=hashicorp/vault
ARG VAULT_VERSION=1.21.4

# renovate: datasource=github-releases depName=open-policy-agent/conftest
ARG CONFTEST_VERSION=0.68.2

# renovate: datasource=github-releases depName=tfutils/tfenv
ARG TFENV_VERSION=v3.2.2

# renovate: datasource=github-releases depName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.36.1

# renovate: datasource=github-releases depName=gruntwork-io/terragrunt
ARG TERRAGRUNT=v0.99.5

# renovate: datasource=repology depName=alpine_3_23/postgresql17-client versioning=loose
ARG PSQL_VERSION=17.10-r0

# renovate: datasource=repology depName=alpine_3_23/mysql-client versioning=loose
ARG MYSQL_VERSION=11.4.10

# renovate: datasource=github-releases depName=topfreegames/helm-diff
ARG HELM_DIFF_VERSION=v3.15.6-1

# renovate: datasource=github-releases depName=open-policy-agent/opa
ARG OPA_VERSION=v1.16.2

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
