#!/bin/bash
#
# // Copyright (C) 2023 Salman Wahib / NodeX Capital Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "        ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "       ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "      ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "     ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "  Cosmovisor Automatic Installer for Crossfi Chain ID : crossfi-evm-testnet-1";
echo -e "\e[0m"
sleep 1

# Variable
#SOURCE=crossfi
WALLET=wallet
BINARY=crossfid
CHAIN=crossfi-evm-testnet-1
CROSSFI_FOLDER=.mineplex-chain
#VERSION=0.3.0-prebuild3
DENOM=mpx
REPO=https://github.com/crossfichain/crossfi-node/releases/download/v0.3.0-prebuild3/crossfi-node_0.3.0-prebuild3_linux_amd64.tar.gz
#COSMOVISOR=cosmovisor
GENESIS=https://testnet-files.itrocket.net/crossfi/genesis.json
ADDRBOOK=https://testnet-files.itrocket.net/crossfi/addrbook.json
PORT=09

# Set Vars
if [ ! $NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODENAME] > " NODENAME
        echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi

echo "Verify the information below before proceeding with the installation!"
echo ""
echo -e "NODE NAME      : \e[1m\e[35m$NODENAME\e[0m"
echo -e "WALLET NAME    : \e[1m\e[35m$WALLET\e[0m"
echo -e "CHAIN NAME     : \e[1m\e[35m$CHAIN\e[0m"
#echo -e "NODE VERSION   : \e[1m\e[35m$VERSION\e[0m"
echo -e "NODE FOLDER    : \e[1m\e[35m$CROSSFI_FOLDER\e[0m"
echo -e "NODE DENOM     : \e[1m\e[35m$DENOM\e[0m"
#echo -e "NODE ENGINE    : \e[1m\e[35m$COSMOVISOR\e[0m"
echo -e "SOURCE CODE    : \e[1m\e[35m$REPO\e[0m"
echo -e "NODE PORT      : \e[1m\e[35m$PORT\e[0m"
echo ""

read -p "Is the above information correct? (y/n) " choice
if [[ $choice == [Yy]* ]]; then

#echo "export SOURCE=${SOURCE}" >> $HOME/.bash_profile
echo "export WALLET=${WALLET}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export DENOM=${DENOM}" >> $HOME/.bash_profile
echo "export CHAIN=${CHAIN}" >> $HOME/.bash_profile
echo "export CROSSFI_FOLDER=${CROSSFI_FOLDER}" >> $HOME/.bash_profile
#echo "export VERSION=${VERSION}" >> $HOME/.bash_profile
#echo "export COSMOVISOR=${COSMOVISOR}" >> $HOME/.bash_profile
echo "export REPO=${REPO}" >> $HOME/.bash_profile
echo "export GENESIS=${GENESIS}" >> $HOME/.bash_profile
echo "export ADDRBOOK=${ADDRBOOK}" >> $HOME/.bash_profile
echo "export PORT=${PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

else
    echo "Installation cancelled!"
    exit 1
fi

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

# Install GO
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.21.3.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)

# Get testnet version of Crossfi
wget $REPO 
tar -xvf crossfi-node_0.3.0-prebuild3_linux_amd64.tar.gz
chmod +x $HOME/bin/crossfid
mv $HOME/bin/crossfid $HOME/go/bin
rm -rf crossfi-node_0.3.0-prebuild3_linux_amd64.tar.gz $HOME/bin

# Prepare config and init app
crossfid config node tcp://localhost:${CROSSFI_PORT}657
crossfid config keyring-backend os
crossfid config chain-id crossfi-evm-testnet-1
rm -rf testnet ~/$CROSSFI_FOLDER
git clone https://github.com/crossfichain/testnet.git
mv $HOME/testnet/ $HOME/$CROSSFI_FOLDER/

# Set peers and
PEERS="$(curl -sS https://rpc.crossfi-test.hexnodes.one/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's|\n|,|g;s|.$||')"
SEEDS="dd83e3c7c4e783f8a46dbb010ec8853135d29df0@crossfi-testnet-seed.itrocket.net:36656"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$CROSSFI_FOLDER/config/config.toml
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$CROSSFI_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $GENESIS > $HOME/$CROSSFI_FOLDER/config/genesis.json
curl -Ls $ADDRBOOK > $HOME/$CROSSFI_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/$CROSSFI_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%" $HOME/$CROSSFI_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$CROSSFI_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$CROSSFI_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$CROSSFI_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$CROSSFI_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"10000000000000mpx$DENOM\"/" $HOME/$CROSSFI_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$CROSSFI_FOLDER/config/app.toml
$BINARY tendermint unsafe-reset-all --home $HOME/$CROSSFI_FOLDER
curl -L https://testnet-files.itrocket.net/crossfi/snap_crossfi.tar.lz4 | tar -Ilz4 -xf - -C $HOME/$CROSSFI_FOLDER

# Create Service
sudo tee /etc/systemd/system/$BINARY.service > /dev/null << EOF
[Unit]
Description=$BINARY
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/$CROSSFI_FOLDER
ExecStart=$(which crossfid) start --home $HOME/$CROSSFI_FOLDER
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $BINARY
sudo systemctl start $BINARY

echo -e "\033[0;35m=============================================================\033[0m"
echo -e "\033[0;35mCONGRATS! SETUP FINISHED\033[0m"
echo ""
echo -e "CHECK STATUS BINARY : \033[1m\033[35msystemctl status $BINARY\033[0m"
echo -e "CHECK RUNNING LOGS : \033[1m\033[35mjournalctl -fu $BINARY -o cat\033[0m"
echo -e "CHECK LOCAL STATUS : \033[1m\033[35mcurl -s localhost:${PORT}657/status | jq .result.sync_info\033[0m"
echo -e "\033[0;35m=============================================================\033[0m"

# End