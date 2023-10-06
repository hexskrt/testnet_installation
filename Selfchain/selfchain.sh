#!/bin/bash
#
# // Copyright (C) 2023 Salman Wahib Recoded By NodeX Capital
#

echo -e "\033[0;35m"
echo "        ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "       ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "      ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "     ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "   Cosmovisor Automatic Installer for Selfchain | Chain ID : self-dev-1";
echo -e "\e[0m"

sleep 1

# Variable
WALLET=wallet
BINARY=selfchaind
CHAIN=self-dev-1
FOLDER=.selfchain
DENOM=uself
BIN_REPO=https://snapshots.indonode.net/selfchain/selfchaind
COSMOVISOR=cosmovisor
GENESIS=https://raw.githubusercontent.com/hotcrosscom/selfchain-genesis/main/networks/devnet/genesis.json
ADDRBOOK=https://ss-t.self.nodestake.top/addrbook.json
PORT=13

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
echo -e "NODE FOLDER    : \e[1m\e[35m$SELF_FOLDER\e[0m"
echo -e "NODE DENOM     : \e[1m\e[35m$DENOM\e[0m"
echo -e "NODE ENGINE    : \e[1m\e[35m$COSMOVISOR\e[0m"
echo -e "NODE PORT      : \e[1m\e[35m$PORT\e[0m"
echo ""

read -p "Are you sure? (y/n) " choice
if [[ $choice == [Yy]* ]]; then

echo "export WALLET=${WALLET}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export DENOM=${DENOM}" >> $HOME/.bash_profile
echo "export CHAIN=${CHAIN}" >> $HOME/.bash_profile
echo "export SELF_FOLDER=${SELF_FOLDER}" >> $HOME/.bash_profile
#echo "export VERSION=${VERSION}" >> $HOME/.bash_profile
echo "export COSMOVISOR=${COSMOVISOR}" >> $HOME/.bash_profile
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
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.20.5.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)

# Installing Cosmovisor
cd $HOME
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0

# Prepare binaries for Cosmovisor & Download Binaries
mkdir -p $HOME/$SELF_FOLDER/$COSMOVISOR/genesis/bin
wget -O $HOME/$SELF_FOLDER/$COSMOVISOR/genesis/bin/$BINARY $BIN_REPO
chmod +x $HOME/$SELF_FOLDER/$COSMOVISOR/genesis/bin/*

# Create application symlinks
sudo ln -s $HOME/$SELF_FOLDER/$COSMOVISOR/genesis $HOME/$SELF_FOLDER/$COSMOVISOR/current
sudo ln -s $HOME/$SELF_FOLDER/$COSMOVISOR/current/bin/$BINARY /usr/local/bin/$BINARY

# Init generation
$BINARY init $NODENAME --chain-id $CHAIN
$BINARY config chain-id $CHAIN
$BINARY config keyring-backend test
$BINARY config node tcp://localhost:${PORT}657

# Set peers and
PEERS=""
SEEDS="94a7baabb2bcc00c7b47cbaa58adf4f433df9599@157.230.119.165:26656,d3b5b6ca39c8c62152abbeac4669816166d96831@165.22.24.236:26656,35f478c534e2d58dc2c4acdf3eb22eeb6f23357f@165.232.125.66:26656"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$SELF_FOLDER/config/config.toml
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$SELF_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $GENESIS > $HOME/$SELF_FOLDER/config/genesis.json
curl -Ls $ADDRBOOK > $HOME/$SELF_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT}660\"%" $HOME/$SELF_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${PORT}317\"%; s%^address = \":8080\"%address = \":${PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT}091\"%" $HOME/$SELF_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$SELF_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$SELF_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$SELF_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$SELF_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.005$DENOM\"/" $HOME/$SELF_FOLDER/config/app.toml

# Disable Indexer
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/$SELF_FOLDER/config/config.toml

# Enable State Sync
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$SELF_FOLDER/config/app.toml
$BINARY tendermint unsafe-reset-all --home $HOME/$SELF_FOLDER
SNAP_NAME=$(curl -s https://ss-t.self.nodestake.top/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")
curl -o - -L https://ss-t.self.nodestake.top/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/$SELF_FOLDER
[[ -f $HOME/$SELF_FOLDER/data/upgrade-info.json ]] && cp $HOME/$SELF_FOLDER/data/upgrade-info.json $HOME/$SELF_FOLDER/cosmovisor/genesis/upgrade-info.json

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
Environment="DAEMON_HOME=$HOME/$SELF_FOLDER"
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
echo -e "CHECK LOCAL STATUS : \033[1m\033[35mcurl -s localhost:${PORT}657/status | jq .result.sync_info\033[0m"
echo -e "\033[0;35m=============================================================\033[0m"

# End
