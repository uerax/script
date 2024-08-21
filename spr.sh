RLS="https://api.github.com/repos/spectre-project/spectre-miner/releases/latest"
ADDRESS="spectre:qrkrhmu0lak80fjp5kuhaucn6wwc8858zx2sd4uuv6clja6y74wr5l0t07aln"
CORE=$(nproc)

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

install() {
    apt-get install zip -y
    mkdir -p /root/spr
    cd /root/spr
    rls_info=$(curl -sL $RLS)
    download_url=$(echo $rls_info | grep "browser_download_url" | cut -d '"' -f 4 | grep "linux-gnu-amd64.zip" | head -n1)
    tags=$(echo $rls_info | grep "tag_name" | cut -d '"' -f 4 | head -n1)
    curl -L "$download_url" -o spr.zip
    unzip spr.zip
    rm spr.zip
    cd bin
    mv "spectre-miner-${tags}-linux-gnu-amd64" spectre-miner
    cat > /etc/systemd/system/spr.service << EOF
[Unit]
Description=spr service
[Service]
ExecStart=/root/bin/spectre-miner --mining-address ${ADDRESS} --spectred-address 146.235.233.40 --threads ${CORE}
[Install]
WantedBy=multi-user.target
EOF
}

run() {
    get_system
    install
}

run