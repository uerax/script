#!/bin/bash

if [ $(id -u) == 0 ]; then
    echo -e "进入安装流程"
    sleep 3
else
    echo -e  "请切使用root用户执行脚本"
    echo -e  "切换root用户命令: sudo su"
    exit 1
fi

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F

apt autoremove -y --purge needrestart
apt purge -y netfilter-persistent
rm -rf /etc/iptables

echo -e "========================================"
echo -e "输入你的密码: "
passwd root

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
# 设置如果用户不能成功登录，在切断连接之前服务器需要等待的时间（以秒为单位）。
sed -i 's/^#LoginGraceTime.*$/LoginGraceTime 30/' /etc/ssh/sshd_config
# 最大尝试次数
sed -i 's/^#MaxAuthTries.*$/MaxAuthTries 3/' /etc/ssh/sshd_config
# 开启 RSA
#sed -i 's/^#RSAAuthentication.*$/RSAAuthentication yes/' /etc/ssh/sshd_config
# 是否使用公钥验证
sed -i 's/^#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config
sed -i 's/^#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config
# 超时
sed -i 's/^#TCPKeepAlive/TCPKeepAlive/' /etc/ssh/sshd_config
sed -i 's/^#ClientAliveInterval.*$/ClientAliveInterval 600/' /etc/ssh/sshd_config
sed -i 's/^#ClientAliveCountMax.*$/ClientAliveCountMax 3/' /etc/ssh/sshd_config

port=2222
echo -e "输入SSH要设置的端口(默认2222)"
read -rp "请输入: " input
if [[ $input =~ ^[0-9]+$ ]] && (($input >= 1 && $input <= 65535)); then
    port=${input}
fi

sed -i "s/^#Port.*$/Port ${port}/" /etc/ssh/sshd_config

service sshd restart

echo -e "修改完成"
