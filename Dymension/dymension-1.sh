#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "            Automatic Installer for Dymension Chain ID : 35-C";
echo -e "\e[0m"
sleep 1

# Variable
DYMENSION_WALLET=wallet
DYMENSION=dymd
DYMENSION_ID=35-C
DYMENSION_FOLDER=.dymension
DYMENSION_VER=v0.2.0-beta
DYMENSION_REPO=https://github.com/dymensionxyz/dymension
DYMENSION_DENOM=udym
DYMENSION_PORT=04
DYMENSION_GENESIS=https://raw.githubusercontent.com/obajay/nodes-Guides/main/Dymension/genesis.json
DYMENSION_ADDRBOOK=https://raw.githubusercontent.com/obajay/nodes-Guides/main/Dymension/addrbook.json

echo "export DYMENSION_WALLET=${DYMENSION_WALLET}" >> $HOME/.bash_profile
echo "export DYMENSION=${DYMENSION}" >> $HOME/.bash_profile
echo "export DYMENSION_ID=${DYMENSION_ID}" >> $HOME/.bash_profile
echo "export DYMENSION_FOLDER=${DYMENSION_FOLDER}" >> $HOME/.bash_profile
echo "export DYMENSION_VER=${DYMENSION_VER}" >> $HOME/.bash_profile
echo "export DYMENSION_REPO=${DYMENSION_REPO}" >> $HOME/.bash_profile
echo "export DYMENSION_DENOM=${DYMENSION_DENOM}" >> $HOME/.bash_profile
echo "export DYMENSION_PORT=${DYMENSION_PORT}" >> $HOME/.bash_profile
echo "export DYMENSION_GENESIS=${DYMENSION_GENESIS}" >> $HOME/.bash_profile
echo "export DYMENSION_ADDRBOOK=${DYMENSION_ADDRBOOK}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $DYMENSION_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " DYMENSION_NODENAME
        echo 'export DYMENSION_NODENAME='$DYMENSION_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$DYMENSION_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$DYMENSION_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$DYMENSION_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

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
cd $HOME
rm -rf dymension
git clone $DYMENSION_REPO --branch $DYMENSION_VER
cd dymension
make install

# Init generation
$DYMENSION config chain-id $DYMENSION_ID
$DYMENSION config keyring-backend file
$DYMENSION config node tcp://localhost:${DYMENSION_PORT}657
$DYMENSION init $DYMENSION_NODENAME --chain-id $DYMENSION_ID

# Set peers and seeds
PEERS="562f840c5f6d11ac846f77502198f7c724ef21b9@185.219.142.32:04656"
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
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$DYMENSION_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$DYMENSION_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$DYMENSION_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$DYMENSION_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$DYMENSION_DENOM\"/" $HOME/$DYMENSION_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"1000\"/" $HOME/$DYMENSION_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"2\"/" $HOME/$DYMENSION_FOLDER/config/app.toml

# Enable state sync
$DYMENSION tendermint unsafe-reset-all --home $HOME/$DYMENSION_FOLDER --keep-addr-book

STATE_SYNC_RPC=https://dymension-testnet.rpc.kjnodes.com:443
STATE_SYNC_PEER=d5519e378247dfb61dfe90652d1fe3e2b3005a5b@dymension-testnet.rpc.kjnodes.com:46656
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  -e "s|^persistent_peers *=.*|persistent_peers = \"$STATE_SYNC_PEER\"|" \
  $HOME/.dymension/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$DYMENSION.service > /dev/null <<EOF
[Unit]
Description=$DYMENSION
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $DYMENSION) start --home $HOME/$DYMENSION_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $DYMENSION
sudo systemctl start $DYMENSION

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $DYMENSION -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${DYMENSION_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
