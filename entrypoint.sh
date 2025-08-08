#!/bin/bash
set -e

if [ -z "$WALLET_ADDRESS" ]; then
  echo "Error: WALLET_ADDRESS is not set."
  exit 1
fi

/root/.nexus/bin/nexus-cli register-user --wallet-address "$WALLET_ADDRESS"
/root/.nexus/bin/nexus-cli register-node
/root/.nexus/bin/nexus-cli start
