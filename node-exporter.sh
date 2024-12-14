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

rm -r /root/node_exporter

mkdir -p /root/node_exporter

cd /root/node_exporter

apt-get install tar curl -y

tag=$(curl -sL https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep "tag_name" | cut -d '"' -f 4 | head -n1 | sed 's/^v//')

curl -L "https://github.com/prometheus/node_exporter/releases/download/v$tag/node_exporter-$tag.$release_os-$release_arch.tar.gz" -o node_exporter.tar.gz

tar -vxf node_exporter.tar.gz --strip-components=1 || exit
rm node_exporter.tar.gz

cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=node_exporter service
[Service]
ExecStart=/root/node_exporter/node_exporter
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
