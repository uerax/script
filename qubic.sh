
core=$(nproc)
wallet=''
name=''

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
    echo -e "=======CPU核心数(max:${core})"
    read -rp "请输入: " core
    echo -e "========================================"
    echo -e "=======账号Token: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImM4NjVjNmU1LTBiOTQtNDdjNC04NzBkLThmNTRkOTQ5NzgzMiIsIk1pbmluZyI6IiIsIm5iZiI6MTcwNzczNjA5OSwiZXhwIjoxNzM5MjcyMDk5LCJpYXQiOjE3MDc3MzYwOTksImlzcyI6Imh0dHBzOi8vcXViaWMubGkvIiwiYXVkIjoiaHR0cHM6Ly9xdWJpYy5saS8ifQ.v_VgJJy6jXA-w4aJOo1wtgr7TPHP-2k9MY-8B63qBdv8EjzSWmlh0vx_r-DwF14hG8XrhpXtNv9TgaPyVTVc5Q"
    echo -e "=======钱包地址: ZCTLTDWENTGPABZKMRLGXKKRXNXAONTLZGZCYDWEIBQMJUITAQBGRWSFWDHN"
    read -rp "请输入: " wallet
    echo -e "========================================"
    echo -e "=======标识名称:"
    read -rp "请输入: " name
}

install() {
    apt update
    apt install libc6
    apt install -y g++-11
    wget -O qli-Service-install.sh https://dl.qubic.li/cloud-init/qli-Service-install.sh
    chmod u+x qli-Service-install.sh
    ./qli-Service-install.sh ${core} ${wallet} ${name}
    systemctl start qli
}

run() {
    get_system
    input_param
    install
}

run