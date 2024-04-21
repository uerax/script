RLS="https://api.github.com/repos/Titannet-dao/titan-node/releases/latest"

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

arch() {
    cpu_arch=$(uname -m)
    if [ "$cpu_arch" = "aarch64" ]; then
        echo -e "检测系统为 ARM"
        install_arm
    else
        install
    fi
}

install() {
    apt-get install tar curl
    cd /root
    mkdir titan
    cd titan
    download_url=$(curl -sL $RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "linux_amd64.tar.gz" | head -n1)
    curl -L "$download_url" -o titan.tar.gz
    tar -vxf titan.tar.gz --strip-components=1
    rm titan.tar.gz
    cat > /etc/systemd/system/titan.service << EOF
[Unit]
Description=titan service
[Service]
ExecStart=/root/titan/titan-edge daemon start --init --url https://test-locator.titannet.io:5000/rpc/v0
StandardOutput=append:/var/log/titan.log
StandardError=append:/var/log/err.titan.log
Restart=always
Nice=10
CPUWeight=1
[Install]
WantedBy=multi-user.target
EOF

    systemctl restart titan
    /root/titan/titan-edge bind --hash=B9299B28-DDF7-4649-B84D-424E8E69F06D https://api-test1.container1.titannet.io/api/v2/device/binding
}

install_arm() {
    apt-get install tar curl
    cd /root
    mkdir titan
    cd titan
    download_url=$(curl -sL $RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "arm64" | head -n1)
    curl -L "$download_url" -o titan.tar.gz
    tar -vxf titan.tar.gz --strip-components=1
    rm titan.tar.gz
    cat > /etc/systemd/system/titan.service << EOF
[Unit]
Description=titan service
[Service]
ExecStart=/root/titan/titan-edge daemon start --init --url https://test-locator.titannet.io:5000/rpc/v0
StandardOutput=append:/var/log/titan.log
StandardError=append:/var/log/err.titan.log
Restart=always
Nice=10
CPUWeight=1
[Install]
WantedBy=multi-user.target
EOF

    systemctl restart titan
    /root/titan/titan-edge bind --hash=B9299B28-DDF7-4649-B84D-424E8E69F06D https://api-test1.container1.titannet.io/api/v2/device/binding

}

run() {
    get_system
    arch
}

run