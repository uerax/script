mkdir nock && cd nock  
wget https://github.com/h9-dev/nock-miner/releases/download/v1.0.2/h9-miner-nock-v1.0.2-2-linux.zip -O nock.zip
unzip nock.zip
rm nock.zip 
mv v*/* . && rm -rf v*

sed -i "s~apiKey: \"\"~apiKey: \"nock0000-c7e0-1de1-fb75-d19f0ac2a7f0\"~" config.yaml

    cat > /etc/systemd/system/nock.service << EOF
[Unit]
Description=nock service
[Service]
LimitNOFILE=65536
ExecStart=/root/nock/h9-miner-nock-linux-amd64 -config /root/nock/config.yaml
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload