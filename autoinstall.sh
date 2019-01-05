#!/usr/bin/env bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi

echo "Installing Bitcoin Gold Docker"

mkdir -p $HOME/.btgdocker

echo "Initial Bitcoin Gold Configuration"

read -p 'rpcuser: ' rpcuser
read -p 'rpcpassword: ' rpcpassword

echo "Creating Bitcoin Gold configuration at $HOME/.btgdocker/bitcoingold.conf"

cat >$HOME/.btgdocker/bitcoingold.conf <<EOL
server=1
listen=1
rpcuser=$rpcuser
rpcpassword=$rpcpassword
rpcport=8832
rpcthreads=4
dbcache=8000
par=0
port=8833
rpcallowip=127.0.0.1
rpcallowip=$(curl -s https://canihazip.com/s)
printtoconsole=1
EOL

echo Installing Bitcoin Gold Container

docker volume create --name=btg-data
docker run -v btg-data:/bitcoingold --name=btg-node -d \
      -p 8832:8832 \
      -p 8833:8833 \
      -v $HOME/.btgdocker/bitcoingold.conf:/bitcoingold/.bitcoingold/bitcoingold.conf \
      bitsler/docker-bitcoingold:latest

echo "Creating shell script"

cat >/usr/bin/btg-cli <<'EOL'
#!/usr/bin/env bash
docker exec -it btg-node /bin/bash -c "bgold-cli $*"
EOL

cat >/usr/bin/btg-update <<'EOL'
#!/usr/bin/env bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi
echo "Updating btg..."
sudo docker stop btg-node
sudo docker rm btg-node
sudo docker pull bitsler/docker-bitcoingold:latest
docker run -v btg-data:/bitcoingold --name=btg-node -d \
      -p 8832:8832 \
      -p 8833:8833 \
      -v $HOME/.btgdocker/bitcoingold.conf:/bitcoingold/.bitcoingold/bitcoingold.conf \
      bitsler/docker-bitcoingold:latest
EOL

cat >/usr/bin/btg-rm <<'EOL'
#!/usr/bin/env bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi
echo "WARNING! This will delete ALL btg installation and files"
echo "Make sure your wallet.dat is safely backed up, there is no way to recover it!"
function uninstall() {
  sudo docker stop btg-node
  sudo docker rm btg-node
  sudo rm -rf ~/docker/volumes/btg-data ~/.btgdocker /usr/bin/btg-cli
  sudo docker volume rm btg-data
  echo "Successfully removed"
  sudo rm -- "$0"
}
read -p "Continue (Y)?" choice
case "$choice" in
  y|Y ) uninstall;;
  * ) exit;;
esac
EOL

chmod +x /usr/bin/btg-cli
chmod +x /usr/bin/btg-rm
chmod +x /usr/bin/btg-update

echo
echo "==========================="
echo "==========================="
echo "Installation Complete"
echo "You can now run normal btg-cli commands"
echo "Your configuration file is at $HOME/.btgdocker/bitcoingold.conf"
echo "If you wish to change it, make sure to restart btg-node"
echo "IMPORTANT: To stop btg-node gracefully, use 'btg-cli stop' and wait for the container to stop to avoid corruption"