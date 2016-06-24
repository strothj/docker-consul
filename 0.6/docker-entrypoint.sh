#!/bin/dumb-init /bin/sh
set -e

# Note above that we run dumb-init as PID 1 in order to reap zombie processes
# as well as forward signals to all processes in its session. Normally, sh
# wouldn't do either of these functions so we'd leak zombies as well as do
# unclean termination of all our sub-processes.

# VAULT_DATA_DIR is exposed as a volume for possible persistent storage. The
# VAULT_CONFIG_DIR isn't exposed as a volume but you can compose additional
# config files in there if you use this image as a base, or use VAULT_LOCAL_CONFIG
# below.
VAULT_DATA_DIR=/vault/data
VAULT_CONFIG_DIR=/vault/config

# You can also set the VAULT_LOCAL_CONFIG environemnt variable to pass some
# Vault configuration HCL without having to bind any volumes.
if [ -n "$VAULT_LOCAL_CONFIG" ]; then
	echo "$VAULT_LOCAL_CONFIG" > "$VAULT_CONFIG_DIR/local.hcl"
fi

# If the user is trying to run Vault directly with some arguments, then
# pass them to Vault.
if [ "${1:0:1}" = '-' ]; then
    set -- vault "$@"
fi

# Look for Vault subcommands.
if [ "$1" = 'server' ]; then
    shift
    if [ "$1" = '-dev' ]; then
        set -- vault server -dev \
            -dev-listen-address=":8200"
    else
        set -- vault server \
            -config="$VAULT_CONFIG_DIR" \
            "$@"
    fi
elif [ "$1" = 'version' ]; then
    # This needs a special case because there's no help output.
    set -- vault "$@"
elif vault --help "$1" 2>&1 | grep -q "vault $1"; then
    # We can't use the return code to check for the existence of a subcommand, so
    # we have to use grep to look for a pattern in the help output.
    set -- vault "$@"
fi

# If we are running Vault, make sure it executes as the proper user.
if [ "$1" = 'vault' ]; then
    set -- gosu vault "$@"
fi

setcap cap_ipc_lock=+ep $(readlink -f $(which vault))
exec "$@"
