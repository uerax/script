TW_POOLS_RLS="https://api.github.com/repos/egg5233/ore-hq-client/releases/latest"
M1_POOLS="http://static.m1pool.xyz/m1miner"
SOLO_POOLS="https://github.com/xintai6660707/ore-mine-pool.git"

PASS=$(hostname)
ADDRESS="DAGPCEyGiqQ2wvrQfT6ppKuYKGE2jgejE11UvuEfZkRt"

get_system() {
    source '/etc/os-release'
    if [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]]; then
        echo -e "检测系统为 debian"
    elif [[ "${ID}"=="ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 18 ]]; then
        echo -e "检测系统为 ubuntu"
    elif [[ "${ID}"=="centos" ]]; then
        echo -e  "centos fuck out!"
        exit 1
    else
        echo -e "当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内"
        exit 1
    fi
}

tw_pools() {
    mkdir -p /root/ore
    cd /root/ore
    download_url=$(curl -sL $TW_POOLS_RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "ubuntu22" | head -n1) 
    systemctl stop ore
    curl -L "$download_url" -o ore-hq-client
    chmod +x ore-hq-client
    cat > /etc/systemd/system/ore.service << EOF
[Unit]
Description=ore service
[Service]
ExecStart=/root/ore/ore-hq-client --url ws://ore.tw-pool.com:5487/mine mine --username ${ADDRESS}.${PASS} --cores $(nproc)
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart ore
}

m1_pools() {
    mkdir -p /root/ore
    cd /root/ore
    wget -O ore http://static.m1pool.xyz/m1miner
    chmod +x ore
    cat > /etc/systemd/system/ore.service << EOF
[Unit]
Description=ore service
[Service]
ExecStart=/root/ore/ore wallet=${ADDRESS}
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart ore
}

solo_pools() {
    apt install -y git
    mkdir -p /root/qubic/
    cd /root/qubic/
    git clone "$SOLO_POOLS"
    cat > /etc/systemd/system/ore.service << EOF
[Unit]
Description=ore service
[Service]
ExecStart=/root/qubic/ore-mine-pool/ore-mine-pool-linux worker --alias ${PASS} --route-server-url http://route.oreminepool.top:8080/ --server-url public --worker-wallet-address ${ADDRESS}
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart ore
}

run() {
    get_system
    solo_pools
}

run