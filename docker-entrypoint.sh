#!/bin/dash
set -e

if [ ! -s "$PIVX_DATA/pivx.conf" ]; then
	cat <<-EOF > "$PIVX_DATA/pivx.conf"
	printtoconsole=1
	rpcallowip=::/0
	rpcpassword=${PIVX_RPC_PASSWORD:-password}
	rpcuser=${PIVX_RPC_USER:-pivx}
	EOF
fi

exec "$@"
