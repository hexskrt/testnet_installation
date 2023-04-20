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
echo "    Cosmovisor Automatic Installer for BlockX | Chain ID : blockx_12345-2";
echo -e "\e[0m"

sleep 1

# Variable
WALLET=wallet
BINARY=blockxd
CHAIN=blockx_12345-2
BLOCK_FOLDER=.blockxd
VERSION=0.1.1-test
DENOM=abcx
BIN_REPO=https://github.com/defi-ventures/blockx-node-public-compiled/releases/download/v9.0.0/blockxd
COSMOVISOR=cosmovisor
GENESIS=https://snap.hexnodes.co/blockx/genesis.json
ADDRBOOK=https://snap.hexnodes.co/blockx/addrbook.json
PORT=11

# Set Vars
if [ ! $NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODENAME] > " NODENAME
        echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi

echo "Please make sure the installation information below is correct!"
echo ""
echo -e "NODE NAME      : \e[1m\e[35m$NODENAME\e[0m"
echo -e "WALLET NAME    : \e[1m\e[35m$WALLET\e[0m"
echo -e "CHAIN NAME     : \e[1m\e[35m$CHAIN\e[0m"
echo -e "NODE VERSION   : \e[1m\e[35m$VERSION\e[0m"
echo -e "NODE FOLDER    : \e[1m\e[35m$BLOCKX_FOLDER\e[0m"
echo -e "NODE DENOM     : \e[1m\e[35m$DENOM\e[0m"
echo -e "NODE ENGINE    : \e[1m\e[35m$COSMOVISOR\e[0m"
echo -e "SOURCE CODE    : \e[1m\e[35m$REPO\e[0m"
echo -e "NODE PORT      : \e[1m\e[35m$PORT\e[0m"
echo ""

read -p "Are you sure? (y/n) " choice
if [[ $choice == [Yy]* ]]; then

echo "export SOURCE=${SOURCE}" >> $HOME/.bash_profile
echo "export WALLET=${WALLET}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export DENOM=${DENOM}" >> $HOME/.bash_profile
echo "export CHAIN=${CHAIN}" >> $HOME/.bash_profile
echo "export BLOCKX_FOLDER=${BLOCKX_FOLDER}" >> $HOME/.bash_profile
echo "export VERSION=${VERSION}" >> $HOME/.bash_profile
echo "export COSMOVISOR=${COSMOVISOR}" >> $HOME/.bash_profile
echo "export REPO=${REPO}" >> $HOME/.bash_profile
echo "export GENESIS=${GENESIS}" >> $HOME/.bash_profile
echo "export ADDRBOOK=${ADDRBOOK}" >> $HOME/.bash_profile
echo "export PORT=${PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

else
    echo "Cancelled!"
    exit 1
fi

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

# Install GO
ver="1.19.7"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get testnet version of BlockX
cd $HOME
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

# Prepare binaries for Cosmovisor
mkdir -p $HOME/$BLOCKX_FOLDER/$COSMOVISOR/genesis/bin
wget -O $HOME/$BLOCKX_FOLDER/$COSMOVISOR/genesis/bin/$BINARY $BIN_REPO
chmod +x $HOME/$BLOCKX_FOLDER/$COSMOVISOR/genesis/bin/*

# Create application symlinks
ln -s $HOME/$BLOCKX_FOLDER/$COSMOVISOR/genesis $HOME/$BLOCKX_FOLDER/$COSMOVISOR/current
sudo ln -s $HOME/$BLOCKX_FOLDER/$COSMOVISOR/current/bin/$BINARY /usr/local/bin/$BINARY

# Init generation
$BINARY config chain-id $CHAIN
$BINARY config keyring-backend test
$BINARY config node tcp://localhost:${PORT}657
$BINARY init $NODENAME --chain-id $CHAIN

# Set peers and seeds
SEEDS="772042fa1777c77a6d0349c034396db420da836f@65.109.28.226:07656"
PEERS="$(curl -sS https://rpc-test.blockx.hexnodes.co/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's|\n|,|g;s|.$||')"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$BLOCKX_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$BLOCKX_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $GENESIS > $HOME/$BLOCKX_FOLDER/config/genesis.json
curl -Ls $ADDRBOOK > $HOME/$BLOCKX_FOLDER/config/addrbook.json

# EVM Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"tcp://127.0.0.1:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \"127.0.0.1:${PORT}660\"%" $HOME/$BLOCKX_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://127.0.0.1:${PORT}317\"%; s%^address = \":8080\"%address = \"127.0.0.1:${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"127.0.0.1:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"127.0.0.1:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"127.0.0.1:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"127.0.0.1:${PORT}546\"%" $HOME/$BLOCKX_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$BLOCKX_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$BLOCKX_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$BLOCKX_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$BLOCKX_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$DENOM\"/" $HOME/$BLOCKX_FOLDER/config/app.toml

# Set Interval & Snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$BLOCKX_FOLDER/config/app.toml
$BINARY tendermint unsafe-reset-all --home $HOME/$BLOCKX_FOLDER --keep-addr-book
curl -L https://snap.hexnodes.co/blockx/blockx.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/$BLOCKX_FOLDER
[[ -f $HOME/$BLOCKX_FOLDER/data/upgrade-info.json ]] && cp $HOME/$BLOCKX_FOLDER/data/upgrade-info.json $HOME/$BLOCKX_FOLDER/cosmovisor/genesis/upgrade-info.json

# Create Service
sudo tee /etc/systemd/system/$BINARY.service > /dev/null << EOF
[Unit]
Description=$BINARY
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/$BLOCKX_FOLDER"
Environment="DAEMON_NAME=$BINARY"
Environment="UNSAFE_SKIP_BACKUP=true"

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
echo -e "CHECK LOCAL STATUS : \033[1m\033[35mcurl -s localhost:${PORT}57/status | jq .result.sync_info\033[0m"
echo -e "\033[0;35m=============================================================\033[0m"

# End
