#!/usr/bin/env bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
stty erase ^?

ALGO="RandomX"
POOL=""
WALLET=""
TLS="true"

is_root() {
    if [ $(id -u) == 0 ]; then
        echo -e "进入安装流程"
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

input_param() {
    echo -e "========================================"
    read -rp "输入矿池链接和端口: " pool_tmp
    POOL=${pool_tmp}
    echo -e "========================================"
    read -rp "输入你的钱包地址: " wallet_tmp
    WALLET=${wallet_tmp}
    echo -e "========================================"
    read -rp "输入算法 (默认RandomX): " algo_tmp
    if [ -n "$algo_tmp" ]; then
    ALGO=${algo_tmp}
    fi
    echo -e "========================================"
    read -rp "是否开启TLS(true/false): " tls_tmp
    case $tls_tmp in
    "false")
    TLS="false"
    ;;
    *)
    ;;
    esac

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
    cp xmrig /root/ && cd .. && cp src/config.json /root/
}

filling_param() {
    sed -i "s~\"algo\": null~\"algo\": \"${ALGO}\"~" /root/config.json
    sed -i "s~\"tls\": false~\"tls\": ${TLS}~" /root/config.json
    sed -i "s~donate.v2.xmrig.com:3333~${POOL}~" /root/config.json
    sed -i "s~YOUR_WALLET_ADDRESS~${WALLET}~" /root/config.json
}

systemd_file() {
    cat > /etc/systemd/system/xmrig.service << EOF
[Unit]
Description=miner service
[Service]
ExecStart=/root/xmrig --config=/root/config.json
Restart=always
Nice=10
CPUWeight=1
[Install]
WantedBy=multi-user.target
EOF
}

optimize_sys() {
    (grep -q "vm.nr_hugepages" /etc/sysctl.conf || (echo "vm.nr_hugepages=$((1168+$(nproc)))" | tee -a /etc/sysctl.conf)) && sysctl -w vm.nr_hugepages=$((1168+$(nproc)))
}

server_opt() {
    echo -e "========================================"
    echo -e "是否添加开机启动xmrig"
    read -rp "请输入 Y/N (默认N): " enable
    case $enable in
    [yY])
    systemctl enable xmrig
    ;;
    *)
    ;;
    esac
    echo -e "========================================"
    echo -e "是否立刻启动xmrig"
    read -rp "请输入 Y/N (默认Y): " start
    case $start in
    [nN])
    systemctl start xmrig
    ;;
    *)
    ;;
    esac
}

show_info() {
    echo -e "================================"
    echo -e "启动xmrig:"
    echo -e "systemctl start xmrig"
    echo -e "停止xmrig:"
    echo -e "systemctl stop xmrig"
    echo -e "查看xmrig状态:"
    echo -e "systemctl status xmrig"
    echo -e "开机自启:"
    echo -e "systemctl enable xmrig"
    echo -e "关闭开机自启:"
    echo -e "systemctl disable xmrig"
    echo -e "================================"
}

go() {
    is_root
    get_system
    input_param
    xmrig_compile
    filling_param
    systemd_file
    optimize_sys
    server_opt
    show_info
}

go