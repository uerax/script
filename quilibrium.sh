

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

env() {
    apt install git wget -y
    if ! command -v go >/dev/null 2>&1; then
        golang
    fi
    if ! command -v go >/dev/null 2>&1; then
        go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
    fi

    
}

golang() {
    wget https://go.dev/dl/go1.22.4.linux-amd64.tar.gz
    sudo tar -xvf go1.22.4.linux-amd64.tar.gz
    sudo mv go /usr/local
    sudo rm go1.22.4.linux-amd64.tar.gz
    cat >> ~/.bashrc << EOF
GOROOT=/usr/local/go
GOPATH=$HOME/go
PATH=$GOPATH/bin:$GOROOT/bin:$PATH
EOF
    source ~/.bashrc
}

node() {
    cd ~
    git clone https://github.com/QuilibriumNetwork/ceremonyclient.git
    cd ceremonyclient
    git pull
    git checkout release
    systemctl stop quilibrium

    listenGrpcMultiaddr="/ip4/127.0.0.1/tcp/8337"
    listenRESTMultiaddr="/ip4/127.0.0.1/tcp/8338"
    statsMultiaddr="/dns/stats.quilibrium.com/tcp/443"

    sed -i "s~^\(\s*\)listenGrpcMultiaddr:.*~\1listenGrpcMultiaddr: \"${listenGrpcMultiaddr}\"~" .config/config.yml
    sed -i "s~^\(\s*\)listenRESTMultiaddr:.*~\1listenRESTMultiaddr: \"${listenRESTMultiaddr}\"~" .config/config.yml
    sed -i "s~^\(\s*\)statsMultiaddr:.*~\1statsMultiaddr: \"${statsMultiaddr}\"~" .config/config.yml

    cat > /etc/systemd/system/quilibrium.service << EOF
[Unit]
Description=Ceremony Client Go App Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/ceremonyclient/node
Environment=GOEXPERIMENT=arenas
ExecStart=/root/ceremonyclient/node/release_autorun.sh

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl start quilibrium
}

go() {
    get_system
    env
    node
}   

go