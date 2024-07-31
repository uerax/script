#!/bin/bash

ALGO="RandomX"
POOL="hk-zephyr.miningocean.org:5432"
WALLET="ZEPHs8pacrzaSJHxwUDR4VNa9AiHUADXiFmq8ofmep3G2bD3QSjdogdd8V8o7pWU5cif7DL78Szsk2HoKaHmXonnCR3RdqAEkiX"
TLS="true"
NAME=$(hostname)

XMRIG_RLS="https://api.github.com/repos/xmrig/xmrig/releases/latest"

is_root() {
    if [ $(id -u) == 0 ]; then
        echo -e "进入安装流程"
        apt purge needrestart -y
        sleep 3
    else
        echo -e  "请切使用root用户执行脚本"
        echo -e  "切换root用户命令: sudo su"
        exit 1
    fi
}

get_system() {
    source '/etc/os-release'
    if [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]]; then
        echo -e  "检测系统为 debian"
        apt update
    elif [[ "${ID}"=="ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 18 ]]; then
        echo -e  "检测系统为 ubuntu"
        apt update
    elif [[ "${ID}"=="centos" ]]; then
        echo -e  "centos fuck out!"
        exit 1
    else
        echo -e  "当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内"
        exit 1
    fi
}

arch() {
    cpu_arch=$(uname -m)
    core_count=$(nproc)
    if [ "$cpu_arch" = "aarch64" ] || [ "$core_count" -ge 3 ]; then
        echo -e "检测系统为 ARM"
        xmrig_compile
    else 
        xmrig_release
    fi
}

xmrig_compile() {
    apt-get install git build-essential cmake automake libtool autoconf -y
    git clone https://github.com/xmrig/xmrig.git xmrig-dir
    cd xmrig-dir
    sed -i "s~kDefaultDonateLevel = 1;~kDefaultDonateLevel = 0;~" src/donate.h
    sed -i "s~kMinimumDonateLevel = 1;~kMinimumDonateLevel = 0;~" src/donate.h
    sed -i "s~donate.v2.xmrig.com~127.0.0.1~" src/net/strategies/DonateStrategy.cpp
    sed -i "s~donate.ssl.xmrig.com~127.0.0.1~" src/net/strategies/DonateStrategy.cpp
    mkdir build && cd scripts
    ./build_deps.sh && cd ../build
    cmake .. -DXMRIG_DEPS=scripts/deps
    make -j$(nproc)
    cp xmrig /root/x && cd .. && cp src/config.json /root/config.json
    cd .. && rm -rf xmrig-dir
}

xmrig_release() {
    apt-get install tar curl
    cd /root
    download_url=$(curl -sL $XMRIG_RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "linux-static-x64")
    curl -L "$download_url" -o xmrig.tar.gz
    tar -vxf xmrig.tar.gz --strip-components=1
    mv xmrig x
    rm xmrig.tar.gz
    rm SHA256SUMS
}

filling_param() {
    sed -i "s~\"algo\": null~\"algo\": \"${ALGO}\"~" /root/config.json
    sed -i "s~\"tls\": false~\"tls\": ${TLS}~" /root/config.json
    sed -i "s~donate.v2.xmrig.com:3333~${POOL}~" /root/config.json
    sed -i "s~YOUR_WALLET_ADDRESS~${WALLET}~" /root/config.json
    sed -i "s~\"x\"~\"${NAME}\"~" /root/config.json
    sed -i "s~^\(\s*\)\"donate-level\":.*~\1\"donate-level\": 0,~" /root/config.json
}

systemd_file() {
    cat > /etc/systemd/system/x.service << EOF
[Unit]
Description=miner service
[Service]
ExecStart=/root/x --config=/root/config.json
Restart=always
Nice=10
CPUWeight=1
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
}


go_install() {
    is_root
    get_system
    arch
    filling_param
    systemd_file
}


go_install