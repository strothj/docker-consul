FROM alpine:3.4
MAINTAINER Jason Strothmann <jason@jasons.io>
# Original maintainer of the Consul image, from which this project was forked:
# MAINTAINER James Phillips <james@hashicorp.com> (@slackpad)

# This is the release of Vault to pull in.
ENV VAULT_VERSION=0.6.0

# This is the release of https://github.com/hashicorp/docker-base to pull in order
# to provide HashiCorp-built versions of basic utilities like dumb-init and gosu.
ENV DOCKER_BASE_VERSION=0.0.4

# Create a vault user and group first so the IDs get set the same way, even as
# the rest of this may change over time.
RUN addgroup vault && \
    adduser -S -G vault vault

# Set up certificates, our base tools, and Vault.
RUN apk add --no-cache ca-certificates gnupg libcap openssl && \
    gpg --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    wget https://releases.hashicorp.com/docker-base/${DOCKER_BASE_VERSION}/docker-base_${DOCKER_BASE_VERSION}_linux_amd64.zip && \
    wget https://releases.hashicorp.com/docker-base/${DOCKER_BASE_VERSION}/docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS && \
    wget https://releases.hashicorp.com/docker-base/${DOCKER_BASE_VERSION}/docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS.sig docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS && \
    grep ${DOCKER_BASE_VERSION}_linux_amd64.zip docker-base_${DOCKER_BASE_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip docker-base_${DOCKER_BASE_VERSION}_linux_amd64.zip && \
    cp bin/gosu bin/dumb-init /bin && \
    wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS && \
    wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify vault_${VAULT_VERSION}_SHA256SUMS.sig vault_${VAULT_VERSION}_SHA256SUMS && \
    grep vault_${VAULT_VERSION}_linux_amd64.zip vault_${VAULT_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin vault_${VAULT_VERSION}_linux_amd64.zip && \
    cd /tmp && \
    rm -rf /tmp/build && \
    apk del gnupg openssl && \
    rm -rf /root/.gnupg

# The /vault/data dir is used by Vault to store state. The agent will be started
# with /vault/config as the configuration directory so you can add additional
# config files in that location.
RUN mkdir -p /vault/data && \
    mkdir -p /vault/config && \
    chown -R vault:vault /vault

# Expose the vault data directory as a volume since there's mutable state in there.
VOLUME /vault/data

# CLI and HTTP are the primary interfaces that applications
# use to interact with Vault.
EXPOSE 8200

# Vault doesn't need root privileges so we run it as the vault user from the
# entry point script. The entry point script also uses dumb-init as the top-level
# process to reap any zombie processes created by Vault sub-processes.
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# By default you'll get a development server that stores everything
# in RAM, exposes a web API, and bootstraps itself. Don't use this configuration
# for production.
CMD ["server", "-dev"]
