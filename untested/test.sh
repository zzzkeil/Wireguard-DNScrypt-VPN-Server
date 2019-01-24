####
clear	 
echo "Step 02 - Systemupdate and Downloads" 
echo
apt update && apt upgrade -y && apt autoremove -y
apt update
apt install make libmnl-dev libelf-dev build-essential pkg-config linux-headers-$(uname -r) -y 
mkdir -p /root/wireguard/src
cd /root/wireguard/src
wget https://git.zx2c4.com/WireGuard/snapshot/WireGuard-0.0.20190123.tar.xz
tar -xvf WireGuard-0.0.20190123.tar.xz
cd /root/wireguard/src/WireGuard-0.0.20190123/src
make
make install
cd
