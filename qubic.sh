
core=$(nproc)
wallet='eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImM4NjVjNmU1LTBiOTQtNDdjNC04NzBkLThmNTRkOTQ5NzgzMiIsIk1pbmluZyI6IiIsIm5iZiI6MTcwOTMxNzMyMSwiZXhwIjoxNzQwODUzMzIxLCJpYXQiOjE3MDkzMTczMjEsImlzcyI6Imh0dHBzOi8vcXViaWMubGkvIiwiYXVkIjoiaHR0cHM6Ly9xdWJpYy5saS8ifQ.EcrODguPntLQuUiislVN_zihzxlAEuN30dt_Yr4-DNoL8SCEf8iAiuPpN7TDbv53UTJ18gOZARKqGsV6yrolbA'
name=''
RQINER_RLS="https://api.github.com/repos/Qubic-Solutions/rqiner-builds/releases/latest"

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
    read -rp "是否手动填写Token(Y/N): " wr_token
    case $wr_token in
    [Yy])
        echo -e "========================================"
        echo -e "=======账号Token: ${wallet}"
        echo -e "=======钱包地址: ZCTLTDWENTGPABZKMRLGXKKRXNXAONTLZGZCYDWEIBQMJUITAQBGRWSFWDHN"
        read -rp "请输入: " wallet
    ;;
    *)
    ;;
    esac
    echo -e "========================================"
    echo -e "=======标识名称:"
    read -rp "请输入: " name
}

input_param_arm() {
    wallet="ZCTLTDWENTGPABZKMRLGXKKRXNXAONTLZGZCYDWEIBQMJUITAQBGRWSFWDHN"
    echo -e "========================================"
    echo -e "=======CPU核心数(max:${core})"
    read -rp "请输入: " core
    echo -e "========================================"
    read -rp "是否手动填写Token(Y/N): " wr_token
    case $wr_token in
    [Yy])
        echo -e "========================================"
        echo -e "=======钱包地址: ZCTLTDWENTGPABZKMRLGXKKRXNXAONTLZGZCYDWEIBQMJUITAQBGRWSFWDHN"
        read -rp "请输入: " wallet
    ;;
    *)
    ;;
    esac
    echo -e "========================================"
    echo -e "=======标识名称:"
    read -rp "请输入: " name
}

install() {
    apt update
    apt purge needrestart -y
    apt install libc6
    apt install -y g++-11
    wget -O qli-Service-install.sh https://dl.qubic.li/cloud-init/qli-Service-install.sh
    chmod u+x qli-Service-install.sh
    ./qli-Service-install.sh ${core} ${wallet} ${name}
    systemctl start qli
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
ExecStart=/root/qli -t ${core} -i ${wallet} --label ${name}
Restart=always
${CPUQuota}
Nice=10
CPUWeight=1
[Install]
WantedBy=multi-user.target
EOF

    systemctl start qli
}

optimize_sys() {
    (grep -q "vm.nr_hugepages" /etc/sysctl.conf || (echo "vm.nr_hugepages=$((1168+$(nproc)))" | tee -a /etc/sysctl.conf)) && sysctl -w vm.nr_hugepages=$((1168+$(nproc)))
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

run() {
    get_system
    input_param
    optimize_sys
    install
}

run_arm() {
    get_system
    input_param_arm
    optimize_sys
    install_arm
}

onekey() {
    get_system
    core="$1"
    name="$2"
    wallet="$3"
    install
}

case $1 in
    onekey)
        onekey $2 $3 $4
        ;;
    *)
        arch
        ;;
esac
