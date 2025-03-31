mkdir -p /root/r5
cd /root/r5
wget http://alist.uerax.eu.org/d/local/r5.tar?sign=ANPpVK_Ss5PoLVBiVOD-RP75Y_tXbWU4gy7bWBCotjU=:0 -O r5.tar

tar -xvf r5.tar

rm r5.tar

cd r5_linux

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
ExecStart=/root/r5

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload

    