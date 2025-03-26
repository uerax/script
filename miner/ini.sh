mkdir -p /root/ini && cd  /root/ini

wget https://github.com/Project-InitVerse/miner/releases/download/v1.0.0/iniminer-linux-x64 -O /root/ini/iniminer-linux-x64

chmod +x /root/ini/iniminer-linux-x64


cat > /root/ini/run.sh << EOF
#!/bin/bash
/root/ini/iniminer-linux-x64 --pool stratum+tcp://0x98F3706C10f91bA060348564D78c887011C36B4C.$(hostname)@pool-c.yatespool.com:31189
EOF

chmod +x /root/ini/run.sh

    cat > /etc/systemd/system/ini.service << EOF
[Unit]
Description=ini Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/ini
ExecStart=/root/ini/run.sh

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload