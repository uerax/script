
cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
apt purge needrestart -y
apt install vim -y

cat >> ~/.vimrc <<EOF
:set mouse-=a
syntax on
EOF

sed -i 's/#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/' /etc/gai.conf

bash -c "$(curl -L https://cdn.jsdelivr.net/gh/uerax/script@master/bashrc.sh)" @