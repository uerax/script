mkdir -p /root/xp && cd  /root/xp

wget https://github.com/xpherechain/Xphere-miner/releases/download/v0.0.2/miner-linux-amd64

chmod +x miner-linux-amd64

cat > /root/xp/run.sh << EOF
#!/bin/bash
PARENT_PROCESS_PID=$$

cd /root/xp

for i in {1..20}
do
        ./miner-linux-amd64 -targetMiner 0x076762aaa2f23f42506e1102f0f24edf5d6cd8f1 -domain https://sgp-mining.x-phere.com &
done

# 等待
wait
EOF

chmod +x run.sh

    cat > /etc/systemd/system/xp.service << EOF
[Unit]
Description=xp Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/xp
ExecStart=/root/xp/run.sh

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload