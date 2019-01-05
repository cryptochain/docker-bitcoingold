# docker-bitcoingold
Docker Image for Bitcoin Gold using Bitcoin-Gold Client

### Quick Start
Create a btg-data volume to persist the bsvd blockchain data, should exit immediately. The btg-data container will store the blockchain when the node container is recreated (software upgrade, reboot, etc):
```
docker volume create --name=btg-data
```
Create a bitcoingold.conf file and put your configurations
```
mkdir -p .btgdocker
nano /home/$USER/.btgdocker/bitcoingold.conf
```

Run the docker image
```
docker run -v btg-data:/bitcoingold --name=btg-node -d \
      -p 8832:8832 \
      -p 8833:8833 \
      -v $HOME/.btgdocker/bitcoingold.conf:/bitcoingold/.bitcoingold/bitcoingold.conf \
      bitsler/docker-bitcoingold:latest
```

Check Logs
```
docker logs -f btg-node
```

Auto Installation
```
sudo bash -c "$(curl -L https://git.io/fh3Sw)"
```
