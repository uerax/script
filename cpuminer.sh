#!/usr/bin/env bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
stty erase ^?

version="v0.0.1"

#fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'

GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

ALGO="yespower"
POOL=""
WALLET=""
TLS="true"
NAME=$(hostname)

cpuminer_RLS="https://api.github.com/repos/rplant8/cpuminer-opt-rplant/releases/latest"

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
    echo -e "${Green}=======矿池链接和端口(url / -o):${Font}"
    read -rp "请输入: " pool_tmp
    POOL=${pool_tmp}
    echo -e "========================================"
    echo -e "${Green}=======钱包地址(user / -u):${Font}"
    read -rp "请输入: " wallet_tmp
    WALLET=${wallet_tmp}
    echo -e "========================================"
    echo -e "${Green}=======标识名称(pass / -p):${Font}"
    read -rp "请输入: " name_tmp
    NAME=${name_tmp}
    echo -e "========================================"
    echo -e "${Green}=======算法(algo / -a):${Font}"
    read -rp "请输入: " algo_tmp
    ALGO=${algo_tmp}

}

cpuminer_compile() {
    apt-get install build-essential automake libssl-dev libcurl4-openssl-dev libjansson-dev libgmp-dev zlib1g-dev git -y
    git clone https://github.com/JayDDee/cpuminer-opt.git cpuminer-opt
    cd cpuminer-opt
    ./build.sh
    cp cpuminer /root/
}

cpuminer_compile_arm() {
    apt-get install build-essential automake libssl-dev libcurl4-openssl-dev libjansson-dev libgmp-dev zlib1g-dev git -y
    git clone https://github.com/JayDDee/cpuminer-opt.git cpuminer-opt
    cd cpuminer-opt
    ./arm-build.sh
    cp cpuminer /root/
}

cpuminer_release() {
    apt-get install tar curl
    cd /root
    download_url=$(curl -sL $cpuminer_RLS | grep "browser_download_url" | grep linux | cut -d '"' -f 4)
    curl -L "$download_url" -o cpuminer.tar.gz
    mkdir -p cpuminer-opt
    tar -vxf cpuminer.tar.gz -C ./cpuminer-opt/
    cp cpuminer-opt/cpuminer-sse2amd /root/cpuminer
    rm cpuminer.tar.gz
}

filling_param() {
    param="-a ${ALGO} -o ${POOL} -u ${WALLET} -p ${NAME}"
}

systemd_file() {
    core=$(nproc)
    CPUQuota="CPUQuota=${core}00%"
    echo -e "========================================"
    echo -e "输入CPUQuota限制(max:${core}00)"
    read -rp "请输入(直接回车则不设置): " quota
    if [[ $quota =~ ^[0-9]+$ ]]; then
    CPUQuota="CPUQuota=${quota}%"
    fi
    cat > /etc/systemd/system/cpuminer.service << EOF
[Unit]
Description=miner service
[Service]
ExecStart=/root/cpuminer ${param}
Restart=always
${CPUQuota}
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
    echo -e "是否添加开机启动cpuminer"
    read -rp "请输入 Y/N (默认N): " enable
    case $enable in
    [yY])
    systemctl enable cpuminer
    ;;
    *)
    ;;
    esac
    echo -e "========================================"
    echo -e "是否立刻启动cpuminer"
    read -rp "请输入 Y/N (默认Y): " start
    case $start in
    [nN])
    ;;
    *)
    systemctl start cpuminer
    ;;
    esac
}

show_info() {
    echo -e "================================"
    echo -e "启动cpuminer:"
    echo -e "systemctl start cpuminer"
    echo -e "停止cpuminer:"
    echo -e "systemctl stop cpuminer"
    echo -e "查看cpuminer状态:"
    echo -e "systemctl status cpuminer"
    echo -e "开机自启:"
    echo -e "systemctl enable cpuminer"
    echo -e "关闭开机自启:"
    echo -e "systemctl disable cpuminer"
    echo -e "================================"
}

change_param() {
    echo -e "${Green}=======矿池链接(url / -o):${Font}"
    read -rp "请输入: " pool_tmp
    POOL=$pool_tmp

    echo -e "========================================"
    echo -e "${Green}=======钱包地址(user / -u):${Font}"
    read -rp "请输入: " wallet_tmp
    WALLET=$wallet_tmp

    echo -e "========================================"
    echo -e "${Green}=======标识名称(pass / -p):${Font}"
    read -rp "请输入: " name_tmp
    NAME=$name_tmp

    echo -e "========================================"
    echo -e "${Green}=======算法(algo / -a):${Font}"
    read -rp "请输入: " algo_tmp
    ALGO=$algo_tmp

    filling_param
    systemd_file
    systemctl daemon-reload

}

go_compile() {
    is_root
    get_system
    input_param
    cpuminer_compile
    filling_param
    systemd_file
    optimize_sys
    server_opt
    show_info
}

go_compile_arm() {
    is_root
    get_system
    input_param
    cpuminer_compile_arm
    filling_param
    systemd_file
    optimize_sys
    server_opt
    show_info
}

go_release() {
    is_root
    get_system
    input_param
    cpuminer_release
    filling_param
    systemd_file
    optimize_sys
    server_opt
    show_info
}



menu() {
    echo -e "${Cyan}——————————————— 脚本信息 ———————————————${Font}"
    echo -e "\t\t${Yellow}一键挖矿脚本${Font}"
    echo -e "\t${Yellow}---authored by uerax---${Font}"
    echo -e "\t${Yellow}https://github.com/uerax${Font}"
    echo -e "\t\t${Yellow}版本号：${version}${Font}"
    echo -e "${Cyan}——————————————— 安装向导 ———————————————${Font}"
    echo -e "${Green}1)   编译安装${Font}"
    echo -e "${Green}2)   发布版本安装${Font}"
    echo -e "${Green}3)   ARM 编译安装${Font}"
    echo -e "${Yellow}9)   修改参数${Font}"
    echo -e "${Red}q)   退出${Font}"
    echo -e "${Cyan}————————————————————————————————————————${Font}\n"

    read -rp "输入数字(回车确认)：" menu_num
    echo -e ""
    case $menu_num in
    1)
    go_compile
    ;;
    2)
    go_release
    ;;
    2)
    go_compile_arm
    ;;
    9)
    change_param
    ;;
    q)
    ;;
    *)
    error "请输入正确的数字"
    ;;
    esac
}

menu