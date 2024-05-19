- [Normal](#normal)
- [Mining](#mining)

## Normal

__Xray / Sing-box 一键脚本__

```
bash -c "$(curl -L https://raw.githubusercontent.com/uerax/taffy-onekey/master/taffy.sh)" @
```

***

__Linux 命令优化__

```
bash -c "$(curl -L https://cdn.jsdelivr.net/gh/uerax/script@master/bashrc.sh)" @
```

***

__一键修改 Root 密码和端口__

```
bash -c "$(curl -L https://cdn.jsdelivr.net/gh/uerax/script@master/ssh.sh)" @
```

***

__Mac 工具备份脚本__

```
bash -c "$(curl -L https://mirror.ghproxy.com/https://raw.githubusercontent.com/uerax/script/master/mac-recover.sh)" @
```

***

__论坛每日签到(手动加入cookie)__

```
wget -N --no-check-certificate -q -O /root/hostloc.sh "https://cdn.jsdelivr.net/gh/uerax/script@master/hostloc.sh" && chmod +x /root/hostloc.sh && ((crontab -l | grep -v "bash /root/hostloc.sh") & echo "0 0 * * * bash /root/hostloc.sh") | crontab -
```

***

__一键 DD 脚本__

```
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') -d 11 -v 64 -port "2222" -p "YOUR_PASSWORD" 
```

`国内机器`

```
bash <(wget --no-check-certificate -qO- 'https://mirror.ghproxy.com/https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') -d 11 -v 64 -port "2222" --mirror 'https://mirrors.cloud.tencent.com/debian/' -p "YOUR_PASSWORD" 
```

***

__甲骨文机器基本功能安装__

```
bash -c "$(curl -L https://cdn.jsdelivr.net/gh/uerax/script@master/oracle.sh)" @
```

***

## Mining

__一键安装 Xmrig 脚本 (randomx, ghostrider, cryptonight...)__

```
bash -c "$(curl -L https://raw.githubusercontent.com/uerax/script/master/xmrig.sh)" @
```

`一键修改参数`

```
bash -c "$(curl -L https://raw.githubusercontent.com/uerax/script/master/xmrig.sh)" @ change 矿池链接 钱包地址 标识名 算法 tls(true/false)
```

***

__一键安装 Cpuminer 脚本 (yespower, yescrypt...)__

```
bash -c "$(curl -L https://raw.githubusercontent.com/uerax/script/master/cpuminer.sh)" @
```

***

__一键安装 Qubic 脚本__

```
bash -c "$(curl -L https://raw.githubusercontent.com/uerax/script/master/qubic.sh)" @
```

`客户端更新`

```
bash -c "$(curl -L https://raw.githubusercontent.com/uerax/script/master/qubic.sh)" @ update
```

`一键安装运行`

```
bash -c "$(curl -L https://raw.githubusercontent.com/uerax/script/master/qubic.sh)" @ onekey 64 $(hostname) eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImM4NjVjNmU1LTBiOTQtNDdjNC04NzBkLThmNTRkOTQ5NzgzMiIsIk1pbmluZyI6IiIsIm5iZiI6MTcwNzczNjA5OSwiZXhwIjoxNzM5MjcyMDk5LCJpYXQiOjE3MDc3MzYwOTksImlzcyI6Imh0dHBzOi8vcXViaWMubGkvIiwiYXVkIjoiaHR0cHM6Ly9xdWJpYy5saS8ifQ.v_VgJJy6jXA-w4aJOo1wtgr7TPHP-2k9MY-8B63qBdv8EjzSWmlh0vx_r-DwF14hG8XrhpXtNv9TgaPyVTVc5Q
```

***

__一键安装 Titan 脚本__

```
bash -c "$(curl -L https://raw.githubusercontent.com/uerax/script/master/titan.sh)" @
```

***

