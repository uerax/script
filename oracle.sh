
cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys

apt install vim -y

if command -v needrestart >/dev/null 2>&1; then
    apt purge needrestart -y
fi

if command -v iptables >/dev/null 2>&1; then
    # 主要针对oracle vps
    apt purge netfilter-persistent -y
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
fi

cat >> ~/.vimrc <<EOF
:set mouse-=a
syntax on
EOF

journalctl --vacuum-time=1w

sed -i 's/#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/' /etc/gai.conf

bash -c "$(curl -L https://cdn.jsdelivr.net/gh/uerax/script@master/bashrc.sh)" @