
core=$(nproc)
wallet='eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImM4NjVjNmU1LTBiOTQtNDdjNC04NzBkLThmNTRkOTQ5NzgzMiIsIk1pbmluZyI6IiIsIm5iZiI6MTcyMDE5MjgzNiwiZXhwIjoxNzUxNzI4ODM2LCJpYXQiOjE3MjAxOTI4MzYsImlzcyI6Imh0dHBzOi8vcXViaWMubGkvIiwiYXVkIjoiaHR0cHM6Ly9xdWJpYy5saS8ifQ.kSutnsJnBY8h3qwNxqwJbPvTmdiv98OzNMMCCUrtWg_0ejzu_FJfSwS27kSOA7HkhND32aP5oAJoDRalYHG4cQ'
username=$(hostname)
RQINER_RLS="https://api.github.com/repos/Qubic-Solutions/rqiner-builds/releases/latest"

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

input_param() {

    echo -e "========================================"
    echo -e "=======CPU核心数(max:${core})"
    read -rp "请输入: " core
    echo -e "========================================"
    read -rp "是否手动填写Token(Y/N): " wr_token
    case $wr_token in
    [Yy])
        echo -e "========================================"
        echo -e "=======账号Token: ${wallet}"
        echo -e "=======钱包地址: YOGHCTPVRAOHZFXLSIAJIGQNEAEDMTIKMEAKIAXIZCBKNPXUMWJMFLZDRGOI"
        read -rp "请输入: " wallet
    ;;
    *)
    ;;
    esac
    echo -e "========================================"
    echo -e "=======标识名称:"
    read -rp "请输入: " username
}

input_param_arm() {
    wallet="YOGHCTPVRAOHZFXLSIAJIGQNEAEDMTIKMEAKIAXIZCBKNPXUMWJMFLZDRGOI"
    echo -e "========================================"
    echo -e "=======CPU核心数(max:${core})"
    read -rp "请输入: " core
    echo -e "========================================"
    read -rp "是否手动填写Token(Y/N): " wr_token
    case $wr_token in
    [Yy])
        echo -e "========================================"
        echo -e "=======钱包地址: YOGHCTPVRAOHZFXLSIAJIGQNEAEDMTIKMEAKIAXIZCBKNPXUMWJMFLZDRGOI"
        read -rp "请输入: " wallet
    ;;
    *)
    ;;
    esac
    echo -e "========================================"
    echo -e "=======标识名称:"
    read -rp "请输入: " username
}

install() {
    apt purge needrestart -y
    apt install libc6
    apt install -y g++-11
    wget -O qli-Service-install-auto.sh https://dl.qubic.li/cloud-init/qli-Service-install-auto.sh
    chmod u+x qli-Service-install-auto.sh
    ./qli-Service-install-auto.sh ${core} ${wallet} ${username}
    systemctl restart qli
}

install_arm() {
    CPUQuota="CPUQuota=${core}00%"
    apt-get install tar curl
    cd /root
    download_url=$(curl -sL $RQINER_RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "rqiner-aarch64" | grep -v "mobile") 
    curl -L "$download_url" -o qli
    chmod u+x qli
    cat > /etc/systemd/system/qli.service << EOF
[Unit]
Description=rqiner service
[Service]
ExecStart=/root/qli -t ${core} -i ${wallet} --label ${username}
StandardOutput=append:/var/log/qli.log
StandardError=append:/var/log/qli.log
Restart=always
${CPUQuota}
Nice=10
CPUWeight=1
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart qli
}

optimize_sys() {
    hugepage=$[$(nproc)*600/2]
    sed -i '/vm.nr_hugepages=/d' /etc/sysctl.conf
    echo "vm.nr_hugepages=$hugepage" >> /etc/sysctl.conf
    /usr/sbin/sysctl -w vm.nr_hugepages=${hugepage}
}

arch() {
    cpu_arch=$(uname -m)
    if [ "$cpu_arch" = "aarch64" ]; then
        echo -e "检测系统为 ARM"
        run_arm
    else
        run
    fi
}

arch_update() {
    cpu_arch=$(uname -m)
    if [ "$cpu_arch" = "aarch64" ]; then
        echo -e "检测系统为 ARM"
        update_arm
    else
        update
    fi
}

run() {
    is_root
    get_system
    input_param
    optimize_sys
    install
}

run_arm() {
    is_root
    get_system
    input_param_arm
    optimize_sys
    install_arm
}

update_arm() {
    is_root
    systemctl stop qli
    cd /root
    download_url=$(curl -sL $RQINER_RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "rqiner-aarch64" | head -n1) 
    curl -L "$download_url" -o qli
    chmod u+x qli
    systemctl start qli
}

update() {
    is_root
    systemctl stop qli
    cp /q/appsettings.json /q/appsettings.json.bak
    wget -O qli-Service-install-auto.sh https://dl.qubic.li/cloud-init/qli-Service-install-auto.sh
    chmod u+x qli-Service-install-auto.sh
    ./qli-Service-install-auto.sh 1 1 1
    mv /q/appsettings.json.bak /q/appsettings.json
    systemctl start qli
}

onekey() {
    is_root
    get_system
    core="$1"
    username="$2"
    wallet="$3"
    install
}

case $1 in
    onekey)
        onekey $2 $3 $4
        ;;
    update)
        arch_update
        ;;
    *)
        arch
        ;;
esac
