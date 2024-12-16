#!/bin/bash

address="0x98F3706C10f91bA060348564D78c887011C36B4C"
server_name="ueraxext"
nproc=$(nproc)
workers=$nproc

if ! command -v figlet &> /dev/null; then
    echo "figlet is not installed. Installing..."
    sudo apt-get install figlet -y
fi

apt install -y bc

install_python() {
    version=$1
    echo "Attempting to install Python $version..."
    if apt-get install -y python$version python$version-venv; then
        echo "Python $version installed successfully."
        return 0
    else
        echo "Failed to install Python $version."
        return 1
    fi
}

install_benchmarker() {

    if [ -d "/root/tig" ]; then
        echo "The tig directory already exists. Deleting it..."
        rm -rf /root/tig
    fi

    echo "Creating the tig directory..."
    mkdir -p /root/tig
    cd /root/tig || exit

    echo "Cloning the tig-monorepo repository..."
    git clone https://github.com/tig-foundation/tig-monorepo.git --branch benchmarker_update

    echo "Updating packages..."
    apt-get update -y

    python_versions=("3.12" "3.11" "3.10" "3.9" "3.8")
    for version in "${python_versions[@]}"; do
        if install_python $version; then
            python_version=$version
            break
        fi
    done

    if [ -z "$python_version" ]; then
        echo "Unable to install a compatible Python version. Stopping the script."
        exit 1
    fi

    echo "Creating and activating the virtual environment with Python $python_version..."
    python$python_version -m venv /root/tig/myenv
    source /root/tig/myenv/bin/activate

    echo "Installing Python dependencies..."
    python$python_version -m pip install -r ./tig-monorepo/tig-benchmarker/requirements.txt
    python$python_version -m pip install requests

    echo "Installing Cargo and rustup..."
    apt-get install -y cargo
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"

    echo "Compiling tig-worker..."
    cd tig-monorepo || exit
    cargo build -p tig-worker --release --target-dir /root/tig

    echo "chmod on tig-worker files..."
    chmod +x /root/tig/release/tig-worker

    echo "Creating systemd service for TIG Worker..."

    cat << EOF > /etc/systemd/system/tig.service
[Unit]
Description=tig
After=network.target

[Service]
ExecStart=/root/tig/myenv/bin/python /root/tig/tig-monorepo/tig-benchmarker/slave.py --ttl 0 --workers $(nproc) --master 1.db1.ext.uerax.eu.org /root/tig/release/tig-worker
WorkingDirectory=/root/tig/tig-monorepo/tig-benchmarker
User=root
Group=root
Restart=always

[Install]	
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
}

update_benchmarker() {
    if [ -d "/root/tig" ]; then
        echo "Stopping the current benchmarker service..."
        systemctl stop tig.service
        echo "Restarting the benchmarker service..."


        cd /root/tig/tig-monorepo/tig-benchmarker || {
            echo "Unable to find the benchmarker directory. The Innovation Forge might not be installed correctly."
            return
        }
        echo "Updating the benchmarker..."
        git fetch --all
        git reset --hard origin/main
        git switch main

        cd /root/tig/tig-monorepo || exit

        source "$HOME/.cargo/env"

        cargo build -p tig-worker --release --target-dir /root/tig

        echo "chmod on tig-worker files..."
        chmod +x /root/tig/release/tig-worker
        systemctl start tig.service
    else
        echo "The Innovation Forge is not installed."
    fi
}

install_node() {

    cat > /etc/systemd/system/tig-node.service <<EOF
[Unit]
Description=Tif-node
After=network.target

[Service]
ExecStart=/root/tig/myenv/bin/python /root/tig/tig-monorepo/tig-benchmarker/master.py /root/tig/config.json
WorkingDirectory=/root/tig/tig-monorepo/tig-benchmarker
User=root
Group=root
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
}

case $1 in
    update)
        update_benchmarker
        ;;
    node)
        install_node
        ;;
    *)
        install_benchmarker
        ;;
esac