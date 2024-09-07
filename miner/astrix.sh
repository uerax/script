
link="https://github.com/astrix-network/astrix-cpu-miner/releases/download/v0.2.4/astrix-cpu-miner-v0.2.4-linux.zip"



is_root() {
    if [ $(id -u) == 0 ]; then
        echo -e "进入安装流程"
        sleep 3
    else
        echo -e  "==================警告==================="
        echo -e  "请切使用root用户执行脚本, 命令: sudo su"
        exit 1
    fi
}

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
    apt install -y zip
    mkdir -p /root/astrix
    cd /root/astrix
    wget $link -O astrix.zip
    unzip astrix.zip
    rm astrix.zip

    chmod u+x astrix-miner

    cat > /etc/systemd/system/astrix.service << EOF
    [Unit]
Description=astrix service
[Service]
ExecStart=/root/astrix/astrix-miner --astrixd-address 150.230.216.154 --mining-address astrix:qzka3pmvt4u5xl55jnejyhmnfmgwve5vgkjzldsxfwzxlagafpmxc7z5hxy2l
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart astrix
}

run() {
    is_root
    get_system
    install
}

run