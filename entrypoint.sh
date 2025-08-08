#!/bin/bash
set -e
/root/.nexus/bin/nexus-cli register-user --wallet-address $WALLET_ADDRESS
/root/.nexus/bin/nexus-cli register-node
/root/.nexus/bin/nexus-cli start
