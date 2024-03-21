
cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
apt purge needrestart -y
apt install vim -y

bash -c "$(curl -L https://cdn.jsdelivr.net/gh/uerax/script@master/bashrc.sh)" @