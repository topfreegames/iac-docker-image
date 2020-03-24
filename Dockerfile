FROM alpine:3

LABEL maintainer="Wildlife Studios"

RUN apk update && \
    apk add --no-cache bash curl grep git py3-pip && \
    curl https://releases.hashicorp.com/vault/1.3.4/vault_1.3.4_linux_amd64.zip --output - | unzip -d /usr/bin/ - && \
    chmod +x /usr/bin/vault && \
    git clone --single-branch --branch choose-tfenv-dir https://github.com/topfreegames/tfenv.git /opt/tfenv && \
    ln -s /opt/tfenv/bin/* /usr/local/bin && \
    pip3 install awscli

ENTRYPOINT [ "/bin/bash" ]
