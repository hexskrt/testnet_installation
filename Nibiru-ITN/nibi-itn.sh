#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "           Automatic Installer for Nibiru Chain ID : nibiru-itn-1 ";
echo -e "\e[0m"

sleep 1

# Variable
NIBI_WALLET=wallet
NIBI=nibid
NIBI_ID=nibiru-itn-1
NIBI_FOLDER=.nibid
NIBI_VER=v0.19.2
NIBI_REPO=https://github.com/NibiruChain/nibiru.git
NIBI_GENESIS=https://snapshots.kjnodes.com/nibiru-testnet/genesis.json
NIBI_ADDRBOOK=https://snapshots.kjnodes.com/nibiru-testnet/addrbook.json
NIBI_DENOM=unibi
NIBI_PORT=06

echo "export NIBI_WALLET=${NIBI_WALLET}" >> $HOME/.bash_profile
echo "export NIBI=${NIBI}" >> $HOME/.bash_profile
echo "export NIBI_ID=${NIBI_ID}" >> $HOME/.bash_profile
echo "export NIBI_FOLDER=${NIBI_FOLDER}" >> $HOME/.bash_profile
echo "export NIBI_VER=${NIBI_VER}" >> $HOME/.bash_profile
echo "export NIBI_REPO=${NIBI_REPO}" >> $HOME/.bash_profile
echo "export NIBI_GENESIS=${NIBI_GENESIS}" >> $HOME/.bash_profile
echo "export NIBI_ADDRBOOK=${NIBI_ADDRBOOK}" >> $HOME/.bash_profile
echo "export NIBI_DENOM=${NIBI_DENOM}" >> $HOME/.bash_profile
echo "export NIBI_PORT=${NIBI_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $NIBI_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " NIBI_NODENAME
        echo 'export NIBI_NODENAME='$NIBI_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$NIBI_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$NIBI_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$NIBI_PORT\e[0m"
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

# Get testnet version of andromeda
cd $HOME
rm -rf $NIBI
git clone $NIBI_REPO
cd nibiru
git checkout $NIBI_VER
make install

# Init generation
$NIBI config chain-id $NIBI_ID
$NIBI config keyring-backend test
$NIBI config node tcp://localhost:${NIBI_PORT}657
$NIBI init $NIBI_NODENAME --chain-id $NIBI_ID

# Set peers and seeds
SEEDS="3f472746f46493309650e5a033076689996c8881@nibiru-testnet.rpc.kjnodes.com:39659"
PEERS="d5519e378247dfb61dfe90652d1fe3e2b3005a5b@nibiru-testnet.rpc.kjnodes.com:39656"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$NIBI_FOLDER/config/config.toml
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$NIBI_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $NIBI_GENESIS > $HOME/$NIBI_FOLDER/config/genesis.json
curl -Ls $NIBI_ADDRBOOK > $HOME/$NIBI_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NIBI_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NIBI_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NIBI_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NIBI_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NIBI_PORT}660\"%" $HOME/$NIBI_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NIBI_PORT}317\"%; s%^address = \":8080\"%address = \":${NIBI_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NIBI_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NIBI_PORT}091\"%" $HOME/$NIBI_FOLDER/config/app.toml

# Set Config Pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/$NIBI_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001$NIBI_DENOM\"/" $HOME/$NIBI_FOLDER/config/app.toml

# Enable Statesync
$NIBI tendermint unsafe-reset-all --home $HOME/$NIBI_FOLDER --keep-addr-book
SNAP_RPC="https://nibiru-testnet.rpc.kjnodes.com:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo ""
echo -e "\e[1m\e[31m[!]\e[0m HEIGHT : \e[1m\e[31m$LATEST_HEIGHT\e[0m BLOCK : \e[1m\e[31m$BLOCK_HEIGHT\e[0m HASH : \e[1m\e[31m$TRUST_HASH\e[0m"
echo ""

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$NIBI_FOLDER/config/app.toml

# Create Service
sudo tee /etc/systemd/system/$NIBI.service > /dev/null <<EOF
[Unit]
Description=$NIBI
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $NIBI) start --home $HOME/$NIBI_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $NIBI
sudo systemctl start $NIBI

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $NIBI -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${NIBI_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
