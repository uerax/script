mkdir -p /root/r5
cd /root/r5
wget https://github.com/uerax/script/releases/download/v0.0.1/r5.tar -O r5.tar

tar -xvf r5.tar

rm r5.tar

cat > node.ini <<EOF
[R5 Node Relayer]
network = mainnet
rpc = default
mode = default
miner = true
miner_coinbase = 0x98F3706C10f91bA060348564D78c887011C36B4C
miner_threads = 0
genesis = default
config = default
EOF


    cat > /etc/systemd/system/r5.service << EOF
[Unit]
Description=r5 Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=/root/r5
ExecStart=/root/r5/r5 --network mainnet --rpc --miner coinbase=0x98F3706C10f91bA060348564D78c887011C36B4C threads=$(nproc)

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload

    