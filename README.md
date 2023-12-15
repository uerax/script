## Usage

__alias添加__

```
bash -c "$(curl -L https://cdn.jsdelivr.net/gh/uerax/script@master/bashrc.sh)" @
```

__挖矿脚本__

```
bash -c "$(curl -L https://raw.githubusercontent.com/uerax/script/master/mining.sh)" @
```

__一键修改root密码和端口__

```
bash -c "$(curl -L https://cdn.jsdelivr.net/gh/uerax/script@master/ssh.sh)" @
```

__mac工具备份脚本__

```
bash -c "$(curl -L https://cdn.jsdelivr.net/gh/uerax/script@master/mac-recover.sh)" @
```

__论坛每日签到(手动加入cookie)__

```
wget -N --no-check-certificate -q -O /root/hostloc.sh "https://cdn.jsdelivr.net/gh/uerax/script@master/hostloc.sh" && chmod +x /root/hostloc.sh && ((crontab -l | grep -v "bash /root/hostloc.sh") & echo "0 0 * * * bash /root/hostloc.sh") | crontab -
```