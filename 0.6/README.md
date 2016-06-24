# Vault Unofficial Image Build

This is an unoffical image based on the work done by Hashicorp for their 
[Consul Docker image](https://github.com/hashicorp/docker-consul).

This version is hosted at [Docker Hub strothj/vault](https://hub.docker.com/r/strothj/vault).  
Git hub repo: https://github.com/strothj/docker-vault

From the Consul image README:
> There are several pieces that are used to build this image:
> 
> * We start with an Alpine base image and add CA certificates in order to reach
>   the HashiCorp releases server. These are useful to leave in the image so that
>   the container can access Atlas features as well.
> * Official HashiCorp builds of some base utilities are then included in the
>   image by pulling a release of docker-base. This includes dumb-init and gosu.
>   See https://github.com/hashicorp/docker-base for more details.
> * Finally a specific Consul build is fetched and the rest of the Consul-specific
>   configuration happens according to the Dockerfile.

## Warning
---
Vault manages secrets. This container should be used for experimentation only
due to the importance of the data it manages. I am not a security expert.

## mlock
Vault disables swapping of its memory. To do this, it needs to be able to execute
the `mlock` syscall. To grant the docker container this privilege, use the
`--cap-add=IPC_LOCK` argument with `docker run`.  
The Vault [Server Configuration](https://www.vaultproject.io/docs/config/) page
contains the details.

## Usage
---
Pull the docker image:
```bash
$ docker pull strothj/vault:0.6
```

Start in development mode:
```bash
$ docker run --rm strothj/vault:0.6
```

Help:
```bash
$ docker run --rm strothj/vault:0.6 --help
```

### Start server mode
Example of an unsecure server to demonstrate starting the service instance:
```bash
$ docker run --rm -v $(pwd)/data/:/vault/data/ \ 
  --cap-add=IPC_LOCK \
  -p 8200:8200 \
  -e VAULT_LOCAL_CONFIG='backend "file" { path="/vault/data" } listener "tcp" { address=":8200" tls_disable=1 }' \
  strothj/vault:0.6 server

==> Vault server configuration:

                 Backend: file
              Listener 1: tcp (addr: ":8200", tls: "disabled")
               Log Level: info
                   Mlock: supported: true, enabled: true
                 Version: Vault v0.6.0

==> Vault server started! Log data will stream in below:
```

In another bash instance:
```bash
$ export VAULT_ADDR=http://localhost:8200
$ vault init
Unseal Key 1: 980585d9f2ceb21bb1569a21e61de8e66da09317bb86fb69ab21d871c9d688f101
Unseal Key 2: 896c60574a4da75570ad52a9ed04298f98f2ce85b905a1f5f929dd55a59d57b502
Unseal Key 3: f09673d82dbb11ad6cddbb091a4518e6ea0e03646c6b2409ff97663fbd6719f903
Unseal Key 4: 6f290c4474ec24fbb59cbc06d6a95cea9d34218e58edce6f7e8165d93236cbdb04
Unseal Key 5: 16d31fcb131a9203a9ec55a621e86d83efc8ec6f8d834b93783fdeb32acc859705
Initial Root Token: d8682a99-96f8-c0d1-1489-7ad1551d01c0

Vault initialized with 5 keys and a key threshold of 3. Please
securely distribute the above keys. When the Vault is re-sealed,
restarted, or stopped, you must provide at least 3 of these keys
to unseal it again.

Vault does not store the master key. Without at least 3 keys,
your Vault will remain permanently sealed.
```