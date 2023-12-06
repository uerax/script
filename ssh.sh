#!/bin/bash

if [ $(id -u) == 0 ]; then
    echo -e "进入安装流程"
    sleep 3
else
    echo -e  "请切使用root用户执行脚本"
    echo -e  "切换root用户命令: sudo su"
    exit 1
fi

apt autoremove -y --purge needrestart
apt update

echo -e "========================================"
echo -e "输入你的密码: "
passwd root

sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;

port=2222
echo -e "输入SSH要设置的端口(默认2222)"
read -rp "请输入: " input
if [[ $input =~ ^[0-9]+$ ]] && (($input >= 1 && $input <= 65535)); then
    port=${input}
fi

cat >> /etc/ssh/sshd_config <<EOF
Port ${port}
EOF

service sshd restart
