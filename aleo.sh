RLS="https://api.github.com/repos/zkrush/aleo-pool-client/releases/latest"

get_system() {
    source '/etc/os-release'
    if [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]]; then
        echo -e "检测系统为 debian"
        apt update
    elif [[ "${ID}"=="ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 18 ]]; then
        echo -e "检测系统为 ubuntu"
        apt update
    elif [[ "${ID}"=="centos" ]]; then
        echo -e  "centos fuck out!"
        exit 1
    else
        echo -e "当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内"
        exit 1
    fi
}

install_pool() {
    apt-get install curl wget
    cd /root
    mkdir aleo
    cd aleo
    download_url=$(curl -sL $RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "pool" | head -n1)
    wget "$download_url"
    chmod +x aleo-pool-prover
    download_url=$(curl -sL $RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "license" | head -n1)
    wget "$download_url"
    chmod +r license

    cat > /etc/systemd/system/aleo.service << EOF
[Unit]
Description=aleo service
[Service]
WorkingDirectory=/root/aleo
ExecStart=/root/aleo/aleo-pool-prover --pool wss://aleo.zkrush.com:3333 --account ddbehead --worker-name aleo
Restart=always
Nice=10
CPUWeight=1
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart aleo
}

install_solo() {
    apt-get install curl wget
    cd /root
    mkdir aleo
    cd aleo
    download_url=$(curl -sL $RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "solo" | head -n1)
    wget "$download_url"
    chmod +x aleo-solo-prover
    download_url=$(curl -sL $RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "license" | head -n1)
    wget "$download_url"
    chmod +r license

    cat > /etc/systemd/system/aleo.service << EOF
[Unit]
Description=aleo service
[Service]
WorkingDirectory=/root/aleo
ExecStart=/root/aleo/aleo-solo-prover --proxy wss://vip.aleosolo.com:8888 --address aleo13w0kmfdvt7h3cqrwn5tdcr93l8z0e8fv05830w78exdexnquqcpsp0q7pe --worker-name aleo
Restart=always
Nice=10
CPUWeight=1
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart aleo
}

case $1 in
    pool)
        install_pool
        ;;
    *)
        install_solo
        ;;
esac