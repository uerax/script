curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
sh -c "$(curl -sSfL https://release.solana.com/v1.18.4/install)"
export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
apt install cargo -y
cargo install ore-cli

echo -e "========================================"
echo -e "6xvcoFHV1k2N317GtwAsoKhydyUjvPH71GZNK93cNkwZ"
echo -e "=======输入钱包词"
solana-keygen recover

rpc="https://api.mainnet-beta.solana.com"
echo -e ""========================================""
read -rp "请输入RPC: " rpc

cat > /root/ore.sh << EOF
while true; do
  /root/.cargo/bin/ore --rpc ${rpc} --keypair /root/.config/solana/id.json --priority-fee 1 mine --threads 4
  sleep 2
done
EOF

cat > /etc/systemd/system/ore.service << EOF
[Unit]
Description=miner service
[Service]
ExecStart=/bin/bash /root/ore.sh
StandardOutput=append:/var/log/ore.log
StandardError=append:/var/log/err.ore.log
Restart=always
Nice=10
CPUWeight=1
[Install]
WantedBy=multi-user.target
EOF

systemctl start ore