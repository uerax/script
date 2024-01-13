#!/usr/bin/env bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
stty erase ^?

version="v0.1.2"

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

ALGO="RandomX"
POOL=""
WALLET=""
TLS="true"
NAME=$(hostname)

XMRIG_RLS="https://api.github.com/repos/xmrig/xmrig/releases/latest"

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
    echo -e "矿池链接和端口(url / -o): "
    read -rp "请输入: " pool_tmp
    POOL=${pool_tmp}
    echo -e "========================================"
    echo -e "钱包地址(user / -u): "
    read -rp "请输入: " wallet_tmp
    WALLET=${wallet_tmp}
    echo -e "========================================"
    echo -e "标识名称(pass / -p): "
    read -rp "请输入: " name_tmp
    if [ -n "$name_tmp" ]; then
    NAME=${name_tmp}
    fi
    echo -e "========================================"
    echo -e "算法(algo / -a): "
    read -rp "请输入: " algo_tmp
    if [ -n "$algo_tmp" ]; then
    ALGO=${algo_tmp}
    fi
    echo -e "========================================"
    echo -e "是否开启TLS(tls / --tls)"
    read -rp "请输入(true/false): " tls_tmp
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

xmrig_release() {
    apt-get install tar curl
    cd /root
    download_url=$(curl -sL $XMRIG_RLS | grep "browser_download_url" | cut -d '"' -f 4 | grep "linux-static-x64")
    curl -L "$download_url" -o xmrig.tar.gz
    tar -vxf xmrig.tar.gz --strip-components=1
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
    core=$(nproc)
    CPUQuota="CPUQuota=${core}00%"
    echo -e "========================================"
    echo -e "输入CPUQuota限制(max:${core}00)"
    read -rp "请输入(直接回车则不设置): " quota
    if [[ $quota =~ ^[0-9]+$ ]]; then
    CPUQuota="CPUQuota=${quota}%"
    fi
    cat > /etc/systemd/system/xmrig.service << EOF
[Unit]
Description=miner service
[Service]
ExecStart=/root/xmrig --config=/root/config.json
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
    ;;
    *)
    systemctl start xmrig
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

change_param() {
    cp /root/config.json /root/config.json.old
    cp /root/config.json /root/config.json.tmp
    echo -e "========================================"
    read -rp "是否修改矿池链接(Y/N): " pool_cg
    case $pool_cg in
    [nN])
    ;;
    *)
    echo -e "矿池链接(url / -o):"
    read -rp "请输入: " pool_tmp
    sed -i "s~^\(\s*\)\"url\":.*~\1\"url\": \"${pool_tmp}\",~" /root/config.json.tmp
    ;;
    esac
    
    echo -e "========================================"
    read -rp "是否修改钱包地址(Y/N): " wallet_cg
    case $wallet_cg in
    [nN])
    ;;
    *)
    echo -e "钱包地址(user / -u):"
    read -rp "请输入: " wallet_tmp
    sed -i "s~^\(\s*\)\"user\":.*~\1\"user\": \"${wallet_tmp}\",~" /root/config.json.tmp
    ;;
    esac

    echo -e "========================================"
    read -rp "是否修改标识名称(Y/N): " name_cg
    case $name_cg in
    [nN])
    ;;
    *)
    echo -e "标识名称(pass / -p): "
    read -rp "请输入: " name_tmp
    sed -i "s~^\(\s*\)\"pass\":.*~\1\"pass\": \"${name_tmp}\",~" /root/config.json.tmp
    ;;
    esac

    echo -e "========================================"
    read -rp "是否修改算法(Y/N): " algo_cg
    case $algo_cg in
    [nN])
    ;;
    *)
    echo -e "算法(algo / -a): "
    read -rp "请输入: " algo_tmp
    sed -i "s~^\(\s*\)\"algo\":.*~\1\"algo\": \"${algo_tmp}\",~" /root/config.json.tmp
    ;;
    esac

    echo -e "========================================"
    read -rp "是否修改TLS状态(Y/N): " tls_cg
    case $tls_cg in
    [nN])
    ;;
    *)
    echo -e "是否开启TLS(tls / --tls)"
    read -rp "请输入(true / false): " tls_tmp
    if [[ "$tls_tmp" == "true" || "$tls_tmp" == "false" ]]; then
        sed -i "s~\"tls\": false~\"tls\": ${tls_tmp}~" /root/config.json.tmp
        sed -i "s~\"tls\": true~\"tls\": ${tls_tmp}~" /root/config.json.tmp
    else
        echo "输入值不是true或false,请手动修改"
    fi
    ;;
    esac
    mv /root/config.json.tmp /root/config.json
}

go_compile() {
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

go_release() {
    is_root
    get_system
    input_param
    xmrig_release
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
    echo -e "${Green}2)   发布版本安装(1%手续费)${Font}"
    echo -e "${Yellow}3)   修改参数${Font}"
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
    3)
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