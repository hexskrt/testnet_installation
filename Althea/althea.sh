#!/bin/bash
#
# // Copyright (C) 2023 Salman Wahib / NodeX Capital Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "          ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "         ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "        ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "       ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "      ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "     Cosmovisor Automatic Installer for Althea | Chain ID : althea_417834-3";
echo -e "\e[0m"

sleep 1

# Variable
WALLET=wallet
BINARY=althea
CHAIN=althea_417834-3
ALTHEA_FOLDER=.althea
#VERSION=v0.5.5
DENOM=aalthea
COSMOVISOR=cosmovisor
REPO=https://github.com/althea-net/althea-L1/releases/download/v0.5.5/althea-linux-amd64
BINARY_REPO=althea-linux-amd64
GENESIS=https://raw.githubusercontent.com/althea-net/althea-L1-docs/main/testnet-4-genesis-collected.json
#ADDRBOOK=
PORT=01

# Set Vars
if [ ! $NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODENAME] > " NODENAME
        echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi

echo "Please make sure the installation information below is correct!"
echo ""
echo -e "NODE NAME      : \e[1m\e[32m$NODENAME\e[0m"
echo -e "WALLET NAME    : \e[1m\e[32m$WALLET\e[0m"
echo -e "CHAIN NAME     : \e[1m\e[32m$CHAIN\e[0m""
echo -e "NODE FOLDER    : \e[1m\e[32m$ALTHEA_FOLDER\e[0m"
echo -e "NODE DENOM     : \e[1m\e[32m$DENOM\e[0m"
echo -e "NODE ENGINE    : \e[1m\e[32m$COSMOVISOR\e[0m"
echo -e "SOURCE CODE    : \e[1m\e[32m$REPO\e[0m"
echo -e "NODE PORT      : \e[1m\e[32m$PORT\e[0m"
echo ""

read -p "Are you sure? (y/n) " choice
if [[ $choice == [Yy]* ]]; then

echo "export WALLET=${WALLET}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export DENOM=${DENOM}" >> $HOME/.bash_profile
echo "export CHAIN=${CHAIN}" >> $HOME/.bash_profile
echo "export ALTHEA_FOLDER=${ALTHEA_FOLDER}" >> $HOME/.bash_profile
echo "export COSMOVISOR=${COSMOVISOR}" >> $HOME/.bash_profile
echo "export REPO=${REPO}" >> $HOME/.bash_profile
echo "export BINARY_REPO=${BINARY_REPO}" >> $HOME/.bash_profile
echo "export GENESIS=${GENESIS}" >> $HOME/.bash_profile
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
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.20.5.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)

# Get testnet version of Althea
cd $HOME
wget $REPO 
chmod +x $BINARY_REPO
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0

# Prepare binaries for Cosmovisor
mkdir -p $HOME/$FOLDER/$COSMOVISOR/genesis/bin
mv $BINARY_REPO $HOME/$FOLDER/$COSMOVISOR/genesis/bin/$BINARY

# Create application symlinks
ln -s $HOME/$ALTHEA_FOLDER/$COSMOVISOR/genesis $HOME/$ALTHEA_FOLDER/$COSMOVISOR/current
sudo ln -s $HOME/$ALTHEA_FOLDER/$COSMOVISOR/current/bin/$BINARY /usr/local/bin/$BINARY

# Init generation
$BINARY config keyring-backend test
$BINARY config node tcp://localhost:${PORT}657
$BINARY init $NODENAME --chain-id $CHAIN
$BINARY config chain-id $CHAIN

# Set peers and seeds
PEERS="$(curl -sS https://rpc-t.althea.nodestake.top/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's|\n|,|g;s|.$||')"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$ALTHEA_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$ALTHEA_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $GENESIS > $HOME/$ALTHEA_FOLDER/config/genesis.json
curl -Ls $ADDRBOOK > $HOME/$ALTHEA_FOLDER/config/addrbook.json

# EVM Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"tcp://127.0.0.1:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \"127.0.0.1:${PORT}660\"%" $HOME/$ALTHEA_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://127.0.0.1:${PORT}317\"%; s%^address = \":8080\"%address = \"127.0.0.1:${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"127.0.0.1:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"127.0.0.1:${PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"127.0.0.1:${PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"127.0.0.1:${PORT}546\"%" $HOME/$ALTHEA_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$ALTHEA_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$ALTHEA_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$ALTHEA_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$ALTHEA_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$DENOM\"/" $HOME/$ALTHEA_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$ALTHEA_FOLDER/config/app.toml
$BINARY tendermint unsafe-reset-all --home $HOME/$ALTHEA_FOLDER --keep-addr-book
SNAP_NAME=$(curl -s https://ss-t.althea.nodestake.top/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")
curl -o - -L https://ss-t.althea.nodestake.top/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/$ALTHEA_FOLDER
[[ -f $HOME/$ALTHEA_FOLDER/data/upgrade-info.json ]] && cp $HOME/$ALTHEA_FOLDER/data/upgrade-info.json $HOME/$ALTHEA_FOLDER/cosmovisor/genesis/upgrade-info.json

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
Environment="DAEMON_HOME=$HOME/$ALTHEA_FOLDER"
Environment="DAEMON_NAME=$BINARY"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/$ALTHEA_FOLDER/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $BINARY
sudo systemctl start $BINARY


echo -e "\033[0;32m=============================================================\033[0m"
echo -e "\033[0;32mCONGRATS! SETUP FINISHED\033[0m"
echo ""
echo -e "CHECK STATUS BINARY : \033[1m\033[32msystemctl status $BINARY\033[0m"
echo -e "CHECK RUNNING LOGS : \033[1m\033[32mjournalctl -fu $BINARY -o cat\033[0m"
echo -e "CHECK LOCAL STATUS : \033[1m\033[32mcurl -s localhost:${PORT}657/status | jq .result.sync_info\033[0m"
echo -e "\033[0;32m=============================================================\033[0m"

# End