#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;35m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "           Cosmovisor Automatic Installer for Andromeda Protocol ";
echo -e "\e[0m"
sleep 1

# Variable
ANDRO_WALLET=wallet
ANDRO=andromedad
ANDRO_ID=galileo-3
ANDRO_FOLDER=.andromedad
ANDRO_VER=galileo-3-v1.1.0-beta1
ANDRO_REPO=https://github.com/andromedaprotocol/andromedad.git
ANDRO_DENOM=uandr
ANDRO_PORT=02

echo "export ANDRO_WALLET=${ANDRO_WALLET}" >> $HOME/.bash_profile
echo "export ANDRO=${ANDRO}" >> $HOME/.bash_profile
echo "export ANDRO_ID=${ANDRO_ID}" >> $HOME/.bash_profile
echo "export ANDRO_FOLDER=${ANDRO_FOLDER}" >> $HOME/.bash_profile
echo "export ANDRO_VER=${ANDRO_VER}" >> $HOME/.bash_profile
echo "export ANDRO_REPO=${ANDRO_REPO}" >> $HOME/.bash_profile
echo "export ANDRO_DENOM=${ANDRO_DENOM}" >> $HOME/.bash_profile
echo "export ANDRO_PORT=${ANDRO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $ANDRO_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " ANDRO_NODENAME
        echo 'export ANDRO_NODENAME='$ANDRO_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$ANDRO_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$ANDRO_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$ANDRO_PORT\e[0m"
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
rm -rf andromedad 
cd $HOME
git clone https://github.com/andromedaprotocol/andromedad.git
cd andromedad
git checkout galileo-3-v1.1.0-beta1 
make install
sudo mv build/$ANDRO /usr/bin/

$ANDRO config chain-id $ANDRO_ID
$ANDRO config keyring-backend file
$ANDRO config node tcp://localhost:${ANDRO_PORT}657
$ANDRO init $ANDRO_NODENAME --chain-id $ANDRO_ID

# Set peers and seeds
SEEDS=""
PEERS="117bf8ca700de022d9c87cd7cc7155958dc0ba23@185.188.249.18:02656,06d4ab2369406136c00a839efc30ea5df9acaf11@10.128.0.44:26656,43d667323445c8f4d450d5d5352f499fa04839a8@192.168.0.237:26656,29a9c5bfb54343d25c89d7119fade8b18201c503@192.168.101.79:26656,6006190d5a3a9686bbcce26abc79c7f3f868f43a@37.252.184.230:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.andromedad/config/config.toml

# Create file genesis.json
touch $HOME/$ANDRO_FOLDER/config/genesis.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ANDRO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ANDRO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ANDRO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ANDRO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ANDRO_PORT}660\"%" $HOME/$ANDRO_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ANDRO_PORT}317\"%; s%^address = \":8080\"%address = \":${ANDRO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ANDRO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ANDRO_PORT}091\"%" $HOME/$ANDRO_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$ANDRO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$ANDRO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$ANDRO_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$ANDRO_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$ANDRO_DENOM\"/" $HOME/$ANDRO_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"1000\"/" $HOME/$ANDRO_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"2\"/" $HOME/$ANDRO_FOLDER/config/app.toml

# Enable state sync
$ANDRO tendermint unsafe-reset-all --home $HOME/$ANDRO_FOLDER

SNAP_RPC="https://rpc-test.andromeda.hexskrt.net:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo ""
echo -e "\e[1m\e[31m[!]\e[0m HEIGHT : \e[1m\e[31m$LATEST_HEIGHT\e[0m BLOCK : \e[1m\e[31m$BLOCK_HEIGHT\e[0m HASH : \e[1m\e[31m$TRUST_HASH\e[0m"
echo ""

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$ANDRO_FOLDER/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$ANDRO.service > /dev/null <<EOF
[Unit]
Description=$ANDRO
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $ANDRO) start --home $HOME/$ANDRO_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $ANDRO
sudo systemctl start $ANDRO

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $ANDRO -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${ANDRO_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
