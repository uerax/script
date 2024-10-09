#!/bin/bash

address="0x98F3706C10f91bA060348564D78c887011C36B4C"
server_name="ueraxext"
nproc=$(nproc)
workers=$nproc

if ! command -v figlet &> /dev/null; then
    echo "figlet is not installed. Installing..."
    sudo apt-get install figlet -y
fi

echo "Server name accepted: $server_name"
echo "Make sure this name is unique to avoid conflicts with other benchmarkers."

concat="${address}_${server_name}"
echo "The concatenation of the address and name is: $concat"

if [ -d "/root/tif-miningpool" ]; then
    echo "The tif-miningpool directory already exists. Deleting it..."
    rm -rf /root/tif-miningpool
fi

echo "Creating the tif-miningpool directory..."
mkdir -p /root/tif-miningpool
cd /root/tif-miningpool || exit

echo "Generating the information file..."

echo "address = $address" > address_name
echo "name = $server_name" >> address_name

echo "File address_name created in /root/tif-miningpool"

echo "Cloning the tig-monorepo repository..."
git clone https://github.com/tig-foundation/tig-monorepo.git

echo "Updating packages..."
apt-get update -y

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
python$python_version -m venv /root/tif-miningpool/myenv
source /root/tif-miningpool/myenv/bin/activate

echo "Installing Python dependencies..."
python$python_version -m pip install -r ./tig-monorepo/tig-benchmarker/requirements.txt
python$python_version -m pip install requests

echo "Installing Cargo and rustup..."
apt-get install -y cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

echo "Compiling tig-worker..."
cd tig-monorepo || exit
cargo build -p tig-worker --release

echo "chmod on tig-worker files..."
chmod +x ./target/release/tig-worker

echo "Creating systemd service for TIG Worker..."

cat << EOF > /etc/systemd/system/tif-miningpool.service
[Unit]
Description=Tif-Benchmarking
After=network.target

[Service]
ExecStart=/root/tif-miningpool/myenv/bin/python /root/tif-miningpool/tig-monorepo/tig-benchmarker/slave.py --workers ${workers} --name "${address}_${server_name}_${nproc}" theinnovationforge.tf /root/tif-miningpool/tig-monorepo/target/release/tig-worker
WorkingDirectory=/root/tif-miningpool/tig-monorepo/tig-benchmarker
User=root
Group=root
Restart=always

[Install]	
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start tif-miningpool.service