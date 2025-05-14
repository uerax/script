RLS="https://github.com/tari-project/tari/releases/download/v2.1.1/tari_suite-2.1.1-9012bc0-linux-x86_64.zip"
ADDRESS="1214prXG6MNLpadJq7G8EPLb11Sz7H7PHGVa41UZ7RpKuvcz3YwSEmWBpTGipXbvpVNtPzK6JfexKxYaaFWxe6BAxPS"

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
    rm -r /root/tari
    mkdir -p /root/tari
    cd /root/tari
    curl -L "$RLS" -o tari.zip
    unzip tari.zip
    rm tari.zip
    
    cat > /etc/systemd/system/tari.service << EOF
[Unit]
Description=tari service
[Service]
LimitNOFILE=65536
ExecStart=/root/tari/minotari_miner -p miner.base_node_grpc_address=http://1.jp2.ext.uerax.eu.org:18142 -p miner.wallet_payment_address=1214prXG6MNLpadJq7G8EPLb11Sz7H7PHGVa41UZ7RpKuvcz3YwSEmWBpTGipXbvpVNtPzK6JfexKxYaaFWxe6BAxPS
WorkingDirectory=/root/tari
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
}
