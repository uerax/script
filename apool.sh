core=$(nproc)
QUBIC_SUB="CP_hbnrmxcnci"
QUBIC_RLS="https://api.github.com/repos/apool-io/apoolminer/releases/latest"
QUBIC_RLS_TMP="https://github.com/apool-io/apoolminer/releases/download/v1.6.0/apoolminer_linux_autoupdate_v1.6.0.tar"

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

input_param() {
    echo -e "========================================"
    echo -e "=======CPU核心数(max:${core})"
    read -rp "请输入: " core
    echo -e "========================================"
    echo -e "=======标识名称:"
    read -rp "请输入: " name
}

qubic() {
    CPUQuota="CPUQuota=${core}00%"
    apt-get install tar curl
    cd /root
    systemctl stop apool
    download_url=$(curl -sL $QUBIC_RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "linux" | head -n1) 
    curl -L "$QUBIC_RLS_TMP" -o apool.tar.gz
    mkdir -p /root/apool
    tar -xvf apool.tar.gz --strip-components=1 -C /root/apool
    chmod u+x /root/apool/apoolminer
    cat > /etc/systemd/system/apool.service << EOF
[Unit]
Description=apool service
[Service]
ExecStart=/root/apool/apoolminer --account ${QUBIC_SUB} --gpu-off --pool qubic1.hk.apool.io:3334 -t ${core}
StandardOutput=append:/var/log/apool.log
StandardError=append:/var/log/err.apool.log
Restart=always
${CPUQuota}
Nice=10
CPUWeight=1
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart apool
}

install_qubic() {
    is_root
    get_system
    input_param
    qubic
}

install_qubic