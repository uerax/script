## Usage

__Xray / Singbox 一键脚本__

```
bash -c "$(curl -L https://raw.githubusercontent.com/uerax/taffy-onekey/master/taffy.sh)" @
```

__Linux 命令优化__

```
bash -c "$(curl -L https://cdn.jsdelivr.net/gh/uerax/script@master/bashrc.sh)" @
```

__一键安装 XMRIG 脚本__

```
bash -c "$(curl -L https://raw.githubusercontent.com/uerax/script/master/xmrig.sh)" @
```

__一键安装 Qubic 脚本__

```
bash -c "$(curl -L https://raw.githubusercontent.com/uerax/script/master/qubic.sh)" @
```

__一键修改root密码和端口__

```
bash -c "$(curl -L https://cdn.jsdelivr.net/gh/uerax/script@master/ssh.sh)" @
```

__Mac 工具备份脚本__

```
bash -c "$(curl -L https://mirror.ghproxy.com/https://raw.githubusercontent.com/uerax/script/master/mac-recover.sh)" @
```

__论坛每日签到(手动加入cookie)__

```
wget -N --no-check-certificate -q -O /root/hostloc.sh "https://cdn.jsdelivr.net/gh/uerax/script@master/hostloc.sh" && chmod +x /root/hostloc.sh && ((crontab -l | grep -v "bash /root/hostloc.sh") & echo "0 0 * * * bash /root/hostloc.sh") | crontab -
```

__一键 DD 脚本__

```
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') -d 11 -v 64 -port "2222" -p "YOUR_PASSWORD" 
```

`国内机器`

```
bash <(wget --no-check-certificate -qO- 'https://mirror.ghproxy.com/https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') -d 11 -v 64 -port "2222" --mirror 'https://mirrors.cloud.tencent.com/debian/' -p "YOUR_PASSWORD" 
```