- [Normal](#normal)
- [Mining](#mining)

## Normal

__Xray / Sing-box 一键脚本__

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/taffy-onekey/master/taffy.sh)" @
```

***

__Linux 命令优化__

```
bash -c "$(curl -sL https://cdn.jsdelivr.net/gh/uerax/script@master/bashrc.sh)" @
```

***

__一键修改 Root 密码和端口__

```
bash -c "$(curl -sL https://cdn.jsdelivr.net/gh/uerax/script@master/ssh.sh)" @
```

***

__Mac 工具备份脚本__

```
bash -c "$(curl -sL https://mirror.ghproxy.com/https://raw.githubusercontent.com/uerax/script/master/mac-recover.sh)" @
```

***

__一键 DD 脚本__

```
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') -d 11 -v 64 -port "SSH端口" -p "YOUR_PASSWORD" 
```

`国内机器`

```
bash <(wget --no-check-certificate -qO- 'https://mirror.ghproxy.com/https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') -d 11 -v 64 --mirror 'https://mirrors.cloud.tencent.com/debian/' -port "SSH端口" -p "YOUR_PASSWORD" 
```

***

__甲骨文 Ubuntu 优化__

```
bash -c "$(curl -sL https://cdn.jsdelivr.net/gh/uerax/script@master/oracle.sh)" @
```

***

## Mining

__一键安装 Xmrig 脚本 (randomx, ghostrider, cryptonight...)__

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/script/master/miner/xmrig.sh)" @
```

`一键安装`

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/script/master/miner/xmrig.sh)" @ onekey 矿池链接 钱包地址 标识名 算法(RandomX) tls(true/false)
```

`一键修改参数`

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/script/master/miner/xmrig.sh)" @ change 矿池链接 钱包地址 标识名 算法 tls(true/false)
```

***

__一键安装 Cpuminer 脚本 (yespower, yescrypt...)__

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/script/master/miner/cpuminer.sh)" @
```

***

__一键安装 Zeph 脚本__

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/script/master/miner/zeph.sh)" @
```

***

__一键安装 Ore 脚本__

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/script/master/miner/ore.sh)" @
```

***

__一键安装 Tig 脚本__

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/script/master/miner/tif.sh)" @
```

`一键更新`

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/script/master/miner/tif.sh)" @ update
```

***

__一键安装 Quilibrium 脚本__

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/script/master/miner/quilibrium.sh)" @
```

***

__一键安装 Qubic 脚本__

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/script/master/miner/qubic.sh)" @
```

`客户端更新`

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/script/master/miner/qubic.sh)" @ update
```

`一键安装运行`

```
bash -c "$(curl -sL https://raw.githubusercontent.com/uerax/script/master/miner/qubic.sh)" @ onekey 64 $(hostname) token或者钱包地址
```

***

