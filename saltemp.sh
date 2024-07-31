#!/bin/bash

ALGO="RandomX"
PASS=$(hostname)
POOL="randomx.rplant.xyz:17130"
WALLET="SaLvsCxMx39TnLKTDMf2rkTPLWC1HhbHkFic5sF7YiFZXFcPAWeAWsuEK3KQGJp6zNNW7fqfU2dYHA7hR6c14FYLMJYFSATdUYu.$(hostname)"
TLS="true"

systemctl stop qli

bash -c "$(curl -L https://raw.githubusercontent.com/uerax/script/master/xmrig.sh)" @ onekey ${POOL} ${WALLET} ${PASS} ${ALGO} ${TLS}

systemctl start x