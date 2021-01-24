[![Build status](https://github.com/topfreegames/iac-docker-image/workflows/Publish%20new%20Docker%20image/badge.svg
)](https://github.com/topfreegames/iac-docker-image/actions)
[![Docker Repository on Docker Hub](https://img.shields.io/badge/Docker%20Hub-ready-%23099cec)](https://hub.docker.com/r/tfgco/iac-ci)
[![Docker Repository on Quay](https://img.shields.io/badge/Quay.io-ready-%23BE0000)](https://quay.io/repository/tfgco/iac-ci)

# Infrastructe as Code Image

Image used in our Infrastructe as Code pipelines.

- `awscli`
- `bash`
- `curl`
- `conftest`
- `grep`
- `git`
- `jq`
- `kubectl`
- `make`
- `open-policy-agent`
- `python3`
- `pip43`
- `terragrunt`
- `tfenv`
- `vault`
- `zip`

## AWSCLI notes

This image uses awscli v1 by default. To enable usage of awscli v2 set the AWSCLIV2 environment variable to any value.  

## Latest versions

[![Normal Docker Image Size](https://img.shields.io/docker/v/tfgco/iac-ci/latest?label=normal%20version&color=blue)](https://hub.docker.com/r/tfgco/iac-ci)
[![Normal Docker Image Size](https://img.shields.io/docker/image-size/tfgco/iac-ci/latest?label=normal%20image%20size&color=lightgray)](https://hub.docker.com/r/tfgco/iac-ci)
## Hosted at

Quay: https://quay.io/repository/tfgco/iac-ci

Docker Hub: https://hub.docker.com/r/tfgco/iac-ci
