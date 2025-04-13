rm -r /root/ore-mine-pool

git clone --depth 1 https://github.com/xintai6660707/ore-mine-pool.git

cd ore-mine-pool
chmod +x ore-mine-pool-linux
chmod +x ore-mine-pool-linux-avx512

    cat > /etc/systemd/system/bitz.service << EOF
[Unit]
Description=bitz service
[Service]
LimitNOFILE=65536
ExecStart=/root/ore-mine-pool/ore-mine-pool-linux-avx512 worker --route-server-url 'http://minebitz1.oreminepool.top:8880/' --server-url 'bitz' --worker-wallet-address AuWuKrtJW6yMdxRYGR6rqXVdXYgEJrFhLd3Z15i1Me7D
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload