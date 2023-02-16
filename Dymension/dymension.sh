#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "              Cosmovisor Automatic Installer for Dymension ";
echo -e "\e[0m"
sleep 1

# Variable
DYMENSION_WALLET=wallet
DYMENSION=dymd
BINARY=cosmovisor
DYMENSION_ID=35-C
DYMENSION_FOLDER=.dymension
DYMENSION_VER=v0.2.0-beta
DYMENSION_BINARY=https://github.com/dymensionxyz/dymension.git
DYMENSION_GENESIS=https://raw.githubusercontent.com/obajay/nodes-Guides/main/Dymension/genesis.json
DYMENSION_ADDRBOOK=https://raw.githubusercontent.com/obajay/nodes-Guides/main/Dymension/addrbook.json
DYMENSION_DENOM=udym
DYMENSION_PORT=04

echo "export DYMENSION_WALLET=${DYMENSION_WALLET}" >> $HOME/.bash_profile
echo "export DYMENSION=${DYMENSION}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export DYMENSION_ID=${DYMENSION_ID}" >> $HOME/.bash_profile
echo "export DYMENSION_FOLDER=${DYMENSION_FOLDER}" >> $HOME/.bash_profile
echo "export DYMENSION_VER=${DYMENSION_VER}" >> $HOME/.bash_profile
echo "export DYMENSION_BINARY=${DYMENSION_BINARY}" >> $HOME/.bash_profile
echo "export DYMENSION_BIN=${DYMENSION_BIN}" >> $HOME/.bash_profile
echo "export DYMENSION_GENESIS=${DYMENSION_GENESIS}" >> $HOME/.bash_profile
echo "export DYMENSION_ADDRBOOK=${DYMENSION_ADDRBOOK}" >> $HOME/.bash_profile
echo "export DYMENSION_DENOM=${DYMENSION_DENOM}" >> $HOME/.bash_profile
echo "export DYMENSION_PORT=${DYMENSION_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODENAME] > " NODENAME
        echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[35m$NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[35m$DYMENSION_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[35m$DYMENSION_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install curl build-essential jq chrony lz4 -y

# Install GO
ver="1.19.5"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get testnet version of dymension
curl -Ls $DYMENSION_BINARY/$DYMENSION_VER > $DYMENSION
chmod +x $DYMENSION
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

# Prepare binaries for Cosmovisor
mkdir -p $HOME/$DYMENSION_FOLDER/$BINARY/genesis/bin
mv $DYMENSION $HOME/$DYMENSION_FOLDER/$BINARY/genesis/bin/

# Create application symlinks
ln -s $HOME/$DYMENSION_FOLDER/$BINARY/genesis $HOME/$DYMENSION_FOLDER/$BINARY/current
sudo ln -s $HOME/$DYMENSION_FOLDER/$BINARY/current/bin/$DYMENSION /usr/bin/$DYMENSION

# Create Service
sudo tee /etc/systemd/system/$DYMENSION.service > /dev/null << EOF
[Unit]
Description=$BINARY
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $BINARY) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/$DYMENSION_FOLDER"
Environment="DAEMON_NAME=$DYMENSION"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Register Service
sudo systemctl daemon-reload
sudo systemctl enable $DYMENSION

# Init generation
$DYMENSION config chain-id $DYMENSION_ID
$DYMENSION config keyring-backend file
$DYMENSION config node tcp://localhost:${DYMENSION_PORT}657
$DYMENSION init $DYMENSION_NODENAME --chain-id $DYMENSION_ID

# Set peers and seeds
PEERS="b8d08951d68da03af8f9272bf77684811197c289@95.216.41.160:26656,5d689e09a129c03c003f05850262f03b2433a384@51.79.30.141:26656,8f84d324a2d266e612d06db4a793b0d001ee62a0@38.146.3.200:20556,43426e98064694d407b2165fb24d52980d38f1c9@88.99.3.158:20556,ee2fa87279bc626f9c979093389bd1d6568d96ff@65.109.37.228:36656,af6787b3273dd60e0f809c7e5e2a2a9fd379045e@195.201.195.61:27656,94b63fddfc78230f51aeb7ac34b9fb86bd042a77@146.19.24.43:30585,2d05753b4f5ac3bcd824afd96ea268d9c32ed84d@65.108.132.239:56656,d995d7079d975dea118a16014758838fe5cb8e2d@80.240.29.76:26656,f9d5e36ecc66b48f9fb940a778dd0c3b6b7c3d1d@65.109.106.211:26656,0d30a0790a216d01c9759ab48192d9154381e6c0@136.243.88.91:3240,cb1cc6b4c48b3e311f18b606c663c2dc0fb89b75@74.96.207.62:26656,5c2a752c9b1952dbed075c56c600c3a79b58c395@195.3.220.136:27086,e8a706e3a81a36a6dded6cc02eabaf5d355f4c1d@80.79.5.171:28656,7fc44e2651006fb2ddb4a56132e738da2845715f@65.108.6.45:61256,c6cdcc7f8e1a33f864956a8201c304741411f219@3.214.163.125:26656,55f233c7c4bea21a47d266921ca5fce657f3adf7@168.119.240.200:26656,db0264c412618949ce3a63cb07328d027e433372@146.19.24.101:26646"
SEEDS="c6cdcc7f8e1a33f864956a8201c304741411f219@3.214.163.125:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$DYMENSION_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$DYMENSION_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $DYMENSION_GENESIS > $HOME/$DYMENSION_FOLDER/config/genesis.json
curl -Ls $DYMENSION_ADDRBOOK > $HOME/$DYMENSION_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${DYMENSION_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${DYMENSION_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${DYMENSION_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${DYMENSION_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${DYMENSION_PORT}660\"%" $HOME/$DYMENSION_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${DYMENSION_PORT}317\"%; s%^address = \":8080\"%address = \":${DYMENSION_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${DYMENSION_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${DYMENSION_PORT}091\"%" $HOME/$DYMENSION_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$DYMENSION_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$DYMENSION_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$DYMENSION_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$DYMENSION_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$DYMENSION_DENOM\"/" $HOME/$DYMENSION_FOLDER/config/app.toml

#Start Service
sudo systemctl start $DYMENSION

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK STATUS BINARY : \e[1m\e[31msystemctl status $DYMENSION\e[0m"
echo -e "CHECK RUNNING LOGS  : \e[1m\e[31mjournalctl -fu $DYMENSION -o cat\e[0m"
echo -e "CHECK LOCAL STATUS  : \e[1m\e[31mcurl -s localhost:${DYMENSION_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End