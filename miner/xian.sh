ALGO="monero"
PASS="cdb4e56840d660dee5f92755dec6746de7e34288e4a06791d4224e935d91fee2"
POOL="pool.supportxmr.com:3333"
WALLET="47CU8tzfV1Qj8BAy8CjgX5NQ4tXjJoAMk53iktJjuqZNM3gjqbBWWdoY5Vqu34W5Arge6ePPQJ5ABQh78sT4dxrXTnYzyfw"

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
    elif [[ "${ID}"=="ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 18 ]]; then
        echo -e  "检测系统为 ubuntu"
    elif [[ "${ID}"=="centos" ]]; then
        echo -e  "centos fuck out!"
        exit 1
    else
        echo -e  "当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内"
        exit 1
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
    cp xmrig /root/xian && cd .. && cp src/config.json /root/xian.json
    cd .. && rm -rf xmrig-dir
}


filling_param() {
    sed -i "s~\"coin\": null~\"coin\": \"${ALGO}\"~" /root/config.json
    sed -i "s~donate.v2.xmrig.com:3333~${POOL}~" /root/config.json
    sed -i "s~YOUR_WALLET_ADDRESS~${WALLET}~" /root/config.json
    sed -i "s~\"x\"~\"${PASS}\"~" /root/config.json
    sed -i "s~^\(\s*\)\"donate-level\":.*~\1\"donate-level\": 0,~" /root/config.json
}

systemd_file() {
    cat > /etc/systemd/system/xian.service << EOF
[Unit]
Description=miner service
[Service]
ExecStart=/root/x --config=/root/xian.json
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
    xmrig_compile
    filling_param
    systemd_file
}


go_install