
install_node() {
    cd /root/
    apt install -y git
    (curl -fsSL https://get.docker.com |bash) || exit
    git clone https://github.com/xubiaolin/docker-zerotier-planet.git
    cd docker-zerotier-planet
    ./deploy.sh 
}

install_slaver() {
    curl -s https://install.zerotier.com | sudo bash
    cd /root/
    wget -sL "$1" || exit
    mv planet /var/lib/zerotier-one/   
    systemctl restart zerotier-one.service
    zerotier-cli join "$2"
}

case $1 in
    node)
        install_node
        ;;
    slaver)
        install_slaver $2 $3
        ;;
    *)
        install_slaver
        ;;
esac