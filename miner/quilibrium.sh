#!/usr/bin/env bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        release_os="linux"
    if [[ $(uname -m) == "aarch64"* ]]; then
        release_arch="arm64"
    else
        release_arch="amd64"
    fi
else
    release_os="darwin"
    release_arch="arm64"
fi

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

download_qclient() {
    BASE_URL="https://releases.quilibrium.com"
    QCLIENT_VERSION=$(curl -s https://releases.quilibrium.com/qclient-release | grep -E "^qclient-[0-9]+(\.[0-9]+)*" | sed 's/^qclient-//' | cut -d '-' -f 1 |  head -n 1)
    if [ -z "$QCLIENT_VERSION" ]; then
        echo "⚠️ Warning: Unable to determine the Qclient version automatically. Continuing without it."
        exit 1
    else
        echo "✅ Latest Qclient release: $QCLIENT_VERSION"
    fi
    QCLIENT_BINARY="qclient-$QCLIENT_VERSION-$release_os-$release_arch"
    mkdir -p "/root/ceremonyclient/client"

    if ! cd ~/ceremonyclient/client; then
        echo "❌ Error: Unable to change to the download directory"
        exit 1
    fi

    echo "Downloading $QCLIENT_BINARY..."
    if download_and_overwrite "$BASE_URL/$QCLIENT_BINARY" "$QCLIENT_BINARY"; then
        chmod +x $QCLIENT_BINARY
        # Rename the binary to qclient, overwriting if it exists
        #mv -f "$QCLIENT_BINARY" qclient
        #chmod +x qclient
        #echo "✅ Renamed to qclient and made executable"
    else
        echo "❌ Error during download: manual installation may be required."
        exit 1
    fi

    # Download the .dgst file
    echo "Downloading ${QCLIENT_BINARY}.dgst..."
    download_and_overwrite "$BASE_URL/${QCLIENT_BINARY}.dgst" "${QCLIENT_BINARY}.dgst"

    # Download signature files
    echo "Downloading signature files..."
    for i in {1..20}; do
        sig_file="${QCLIENT_BINARY}.dgst.sig.${i}"
        if wget -q --spider "$BASE_URL/$sig_file" 2>/dev/null; then
            download_and_overwrite "$BASE_URL/$sig_file" "$sig_file"
        fi
    done
}

download_and_overwrite() {
    local url="$1"
    local filename="$2"
    if wget -q -O "$filename" "$url"; then
        echo "✅ Successfully downloaded $filename"
        return 0
    else
        echo "❌ Error: Failed to download $filename"
        return 1
    fi
}

env() {
    apt install git wget -y
    
    if ! command -v go >/dev/null 2>&1; then
        golang
    fi
    # 立即加载更新的环境变量
    export GOROOT=/usr/local/go
    export GOPATH=$HOME/go
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
    go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest   
}

download_node() {
    cd /root/ceremonyclient/node || exit
    files=$(curl https://releases.quilibrium.com/release | grep $release_os-$release_arch)
    new_release=false

    for file in $files; do
        version=$(echo "$file" | cut -d '-' -f 2)
        if ! test -f "./$file"; then
            curl "https://releases.quilibrium.com/$file" > "$file"
            new_release=true
        fi
    done

    chmod +x ./node-$version-$release_os-$release_arch
}

golang() {
    wget https://go.dev/dl/go1.22.4.$release_os-$release_arch.tar.gz
    tar -xzf go1.22.4.$release_os-$release_arch.tar.gz
    mv go /usr/local
    rm go1.22.4.$release_os-$release_arch.tar.gz
    cat >> /root/.bashrc << EOF
GOROOT=/usr/local/go
GOPATH=\$HOME/go
PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH
EOF
}

node() {
    cd ~
    git clone --depth 1 --branch release https://github.com/QuilibriumNetwork/ceremonyclient.git
    cd ceremonyclient/node

    cat > /etc/systemd/system/quili.service << EOF
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
}

run() {
    get_system
    env
    node
    download_node
}

case $1 in
    upgrade)
        download_node
        ;;
    qclient)
        download_qclient
        ;;
    *)
        run
        ;;
esac

