RLS="https://api.github.com/repos/spectre-project/spectre-miner/releases/latest"
TNN_RLS="https://spectredbase.com/tnn/Tnn-miner-0.4.0-beta-1.9"
ADDRESS="spectre:qrec78vtm4yjfjvhz93kzryyrlsqzkay9q06ev9chr8fgewndrj27cawz9jsu"

CORE=$(nproc)
PASS=$(hostname)

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

install() {
    apt-get install zip -y
    mkdir -p /root/spr
    cd /root/spr
    download_url=$(curl -sL $RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "linux-gnu-amd64.zip" | head -n1)
    tags=$(curl -sL $RLS | grep "tag_name" | cut -d '"' -f 4 | head -n1)
    curl -L "$download_url" -o spr.zip
    unzip spr.zip
    rm spr.zip
    cd bin
    mv "spectre-miner-${tags}-linux-gnu-amd64" spectre-miner
    cat > /etc/systemd/system/spr.service << EOF
[Unit]
Description=spr service
[Service]
ExecStart=/root/spr/bin/spectre-miner --mining-address ${ADDRESS} --spectred-address 146.235.233.40 --threads ${CORE}
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart spr
}

install_tnn() {
    mkdir -p /root/spr
    cd /root/spr
    curl -L "$TNN_RLS" -o spectre-miner-tnn
    chmod +x spectre-miner-tnn
    cat > /etc/systemd/system/spr.service << EOF
[Unit]
Description=spr service
[Service]
ExecStart=/root/spr/spectre-miner-tnn --spectre --daemon-address 146.235.233.40 --port 18110 --wallet ${ADDRESS} --worker-name ${PASS}
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart spr
}

run() {
    get_system
    install_tnn
}

run