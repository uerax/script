link="https://github.com/Qubic-Solutions/rqiner-builds/releases/latest/download/rqiner-x86-znver4"

address="YOGHCTPVRAOHZFXLSIAJIGQNEAEDMTIKMEAKIAXIZCBKNPXUMWJMFLZDRGOI"

pass=$(hostname)

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
    mkdir -p /root/qubic
    cd /root/qubic
    curl -L "$link" -o rqiner
    chmod u+x rqiner
    cat > /etc/systemd/system/rqiner.service << EOF
[Unit]
Description=rqiner service
[Service]
ExecStart=/root/qubic/rqiner -t $(nproc) -i $address -l $pass --idle-command "/root/ore/ore wallet=DAGPCEyGiqQ2wvrQfT6ppKuYKGE2jgejE11UvuEfZkRt" --no-pplns
StandardError=append:/var/log/rqiner.log
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart rqiner
}

run() {
    is_root
    get_system
    install
}

run